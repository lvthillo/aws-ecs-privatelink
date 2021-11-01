output "ec2_added_ip" {
  value       = module.ec2_instance_added.public_ip
  description = "The IP of the ec2 in the added VPC"
}

output "vpce_dns" {
  value       = aws_vpc_endpoint.vpce.dns_entry[0]["dns_name"]
  description = "The VPC endpoint DNS"
}