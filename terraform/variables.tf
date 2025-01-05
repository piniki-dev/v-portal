variable "aws_region" {
  type        = string
  default     = "ap-northeast-1"
  description = "デプロイ先のAWSリージョン"
}

variable "aws_az_1a" {
  type        = string
  default     = "ap-northeast-1a"
  description = "サブネットを作成するAZ"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "EC2インスタンス用のキーペア（SSH接続用）"
}

variable "hosted_zone_name" {
  type        = string
  default     = "piniki.dev"
  description = "Route53のHosted Zoneで管理しているドメイン名（末尾のドットは不要）"
}
