<!-- BEGIN_TF_DOCS -->

# Instances Module

This module will create the EC2 instances and all the resources related to it.

| Resource | Type | Description |
| --- | --- | --- |
| Bastion Server | EC2 Instance |  This is the bastion server that will be used to connect to the private instances |
| Private Instances | EC2 Instance | We will create one instance per private subnet available |
| Application Load Balancer | ALB | This is the load balancer that will be used to distribute the traffic to the private instances |
| Target Group | ALB Target Group | This is the target group that will be used to register the private instances |
| SSH Key Pair | Key Pair | This is the key pair that will be used to connect to all the instances |
| Bastion SSH SG | Security Group | This is the security group that will be used to allow the SSH traffic to the bastion server |
| Private Instances SSH SG | Security Group | This is the security group that will be used to allow the traffic from the bastion server to the private instances |
| ALB SG | Security Group | This is the security group that will be used to allow the traffic from the internet to the ALB |
| Private Instances HTTP SG | Security Group | This is the security group that will be used to allow the traffic from the ALB to the private instances |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0.1 |
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0.1 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Image"></a> [Image](#input\_Image) | Data from the Golden Image generated Manifest | `any` | n/a | yes |
| <a name="input_Name"></a> [Name](#input\_Name) | Base name for the resources | `string` | n/a | yes |
| <a name="input_Network"></a> [Network](#input\_Network) | Data from the Network module | `any` | n/a | yes |
| <a name="input_Tags"></a> [Tags](#input\_Tags) | Tags to apply to the resources | `map(string)` | `{}` | no |
| <a name="input_ami_filter_architecture"></a> [ami\_filter\_architecture](#input\_ami\_filter\_architecture) | Bastion Host: AMI architecture to use on the filter | `list(string)` | <pre>[<br>  "amd64"<br>]</pre> | no |
| <a name="input_ami_filter_name"></a> [ami\_filter\_name](#input\_ami\_filter\_name) | Bastion Host: AMI name to use on the filter | `list(string)` | <pre>[<br>  "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"<br>]</pre> | no |
| <a name="input_ami_filter_owners"></a> [ami\_filter\_owners](#input\_ami\_filter\_owners) | Bastion Host: AMI owners to use on the filter | `list(string)` | <pre>[<br>  "099720109477"<br>]</pre> | no |
| <a name="input_ami_filter_virtualization_type"></a> [ami\_filter\_virtualization\_type](#input\_ami\_filter\_virtualization\_type) | Bastion Host: AMI virtualization type to use on the filter | `list(string)` | <pre>[<br>  "hvm"<br>]</pre> | no |
| <a name="input_local_ip"></a> [local\_ip](#input\_local\_ip) | Local IP address to allow SSH access to the instances | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the builder instance | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Bastion_Host_IP_address"></a> [Bastion\_Host\_IP\_address](#output\_Bastion\_Host\_IP\_address) | Public IP address of the bastion host |
| <a name="output_Load_balancer_HTTP_DNS"></a> [Load\_balancer\_HTTP\_DNS](#output\_Load\_balancer\_HTTP\_DNS) | DNS name of the load balancer |
| <a name="output_Private_Instances_IP_addresses"></a> [Private\_Instances\_IP\_addresses](#output\_Private\_Instances\_IP\_addresses) | IP addresses of the private instances |
| <a name="output_SSH_key_Content"></a> [SSH\_key\_Content](#output\_SSH\_key\_Content) | Private SSH key content to connect to all the instances |
| <a name="output_Usernames"></a> [Usernames](#output\_Usernames) | Usernames to connect to all the instances |



## Resources

| Name | Type |
|------|------|
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.alb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.alb_listener_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.alb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.alb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.bastion_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.private_instances_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_shuffle.azs](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [tls_private_key.pvt_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.golden_image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [http_http.local_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |


<!-- END_TF_DOCS -->