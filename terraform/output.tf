output "ec2_public_ip" {
  description = "作成されたEC2インスタンスのパブリックIP"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "作成されたEC2インスタンスのパブリックDNS"
  value       = aws_instance.web.public_dns
}

output "route53_record_fqdn" {
  description = "Route53レコードのFQDN"
  value       = aws_route53_record.www_record.fqdn
}
