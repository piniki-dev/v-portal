############################
# プロバイダー設定
############################
terraform {
  cloud {
    organization = "piniki_dev"
    workspaces {
      name = "v-portal"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }
  required_version = ">= 1.10.3"
}

provider "aws" {
  region = var.aws_region
}

############################
# VPCの作成
############################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "v-portal-vpc"
  }
}

############################
# subnetの作成
############################
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.aws_az_1a

  tags = {
    Name = "v-portal-subnet-public-1a"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.aws_az_1a

  tags = {
    Name = "v-portal-subnet-private-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "v-portal-subnet-public-1c"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "v-portal-subnet-private-1c"
  }
}

############################
# インターネットゲートウェイ
############################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "v-portal-igw"
  }
}

############################
# ルートテーブル
############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "v-portal-rt-public"
  }
}

############################
# ルートテーブルアソシエーション
############################
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

############################
# セキュリティグループ
############################
resource "aws_security_group" "web_sg" {
  name        = "example-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-web-sg"
  }
}

############################
# SSL証明書の取得
############################
data "aws_acm_certificate" "issued" {
  domain   = var.hosted_zone_name
  statuses = ["ISSUED"]
}

############################
# ALB（Application Load Balancer）
############################
resource "aws_lb" "web_alb" {
  name               = "example-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  enable_deletion_protection = false

  tags = {
    Name = "example-web-alb"
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

############################
# ターゲットグループ（ALB -> EC2）
############################
resource "aws_lb_target_group" "web_tg" {
  name     = "example-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "example-web-tg"
  }
}

resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web.id # EC2インスタンスIDを指定
}

############################
# EC2インスタンス
############################
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # SSHで接続して設定したい場合など、キー名を指定する
  key_name = var.key_name

  user_data = <<-EOT
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello World from Terraform!</h1>" > /var/www/html/index.html
              EOT

  tags = {
    Name = "example-web"
  }
}

############################
# Route53データソース（Hosted Zoneの取得）
############################
data "aws_route53_zone" "example_zone" {
  name         = "${var.hosted_zone_name}."
  private_zone = false
}

############################
# DNSレコード作成
############################
resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.example_zone.zone_id
  name    = var.hosted_zone_name
  type    = "A"

  alias {
    name                   = aws_lb.web_alb.dns_name # ALBのDNS名を指定
    zone_id                = aws_lb.web_alb.zone_id  # ALBのゾーンIDを指定
    evaluate_target_health = true                    # ヘルスチェック有効化 (推奨)
  }
}


