output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "instance_public_dns" {
  description = "Public IPv4 DNS address of the EC2 instance"
  value       = aws_instance.app.public_dns
}

output "security_group_id" {
  value = aws_security_group.app-sg.id
}

output "security_group_name" {
  value = aws_security_group.app-sg.name
}
