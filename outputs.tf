/**
 *
 * Outputs
 *
 */

output "Private_instances_IP_addresses" {
  description = "Private IP addresses of instances"
  value       = module.instances.Private_Instances_IP_addresses
}

output "Bastion_Host_IP" {
  description = "Bastion Host public IP address"
  value       = module.instances.Bastion_Host_IP_address
}

output "SSH_key_content" {
  description = "SSH key content"
  value       = module.instances.SSH_key_Content
  sensitive   = true
}

output "Load_blanacer_HTTP_Content" {
  description = "Load balancer public DNS name"
  value       = module.instances.Load_balancer_HTTP_DNS
}

output "Usernames" {
  description = "Usernames for instances"
  value       = module.instances.Usernames
}
