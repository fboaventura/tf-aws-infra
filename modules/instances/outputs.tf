/**
 *
 * Outputs
 *
 */

output "Private_Instances_IP_addresses" {
  description = "IP addresses of the private instances"
  value       = aws_instance.private.*.private_ip
}

output "Bastion_Host_IP_address" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "Load_balancer_HTTP_DNS" {
  description = "DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}

output "SSH_key_Content" {
  description = "Private SSH key content to connect to all the instances"
  value       = tls_private_key.pvt_cert.private_key_pem
  sensitive   = true
}

output "Usernames" {
  description = "Usernames to connect to all the instances"
  value       = "ubuntu"
}
