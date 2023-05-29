<!-- BEGIN_TF_DOCS -->

# Network Module

This module will create the Network related resources.

| Resource | Type | Description |
| --- | --- | --- |
| VPC | VPC | This is the VPC that will be used to create the network |
| Public Subnets | Subnet | We will create one public subnet per availability zone available |
| Private Subnets | Subnet | We will create one private subnet per availability zone available |
| Internet Gateway | Internet Gateway | This is the gateway that will be used to connect the VPC to the internet |
| NAT Gateway | NAT Gateway | This is the gateway that will be used to connect the private subnets to the internet |
| External Route Table | Route Table | This Route Table will allow communication from the public subnets to the Internet |
| Internal Route Table | Route Table | This Route Table will allow communication between the public and private subnets |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.5.1 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_N_Subnets"></a> [N\_Subnets](#input\_N\_Subnets) | The number of subnets to create | `number` | n/a | yes |
| <a name="input_Name"></a> [Name](#input\_Name) | Base name for the resources | `string` | n/a | yes |
| <a name="input_Network_CIDR"></a> [Network\_CIDR](#input\_Network\_CIDR) | The network IP address configuration on CIDR format | `string` | n/a | yes |
| <a name="input_Tags"></a> [Tags](#input\_Tags) | Tags to apply to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Network"></a> [Network](#output\_Network) | Information related to all the created resources |



## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [random_shuffle.azs](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |


<!-- END_TF_DOCS -->