<!-- BEGIN_TF_DOCS -->

# Golden Image Module

This module will create the Golden Image used by the instances associated to the private subnets.

**Attention**: Sometimes the Golden Image creation process fails due to some Ubuntu update/upgrade/install errors.
    If this happens, you can try to run the process again and it will probably work.

| Resource | Type | Description |
| --- | --- | --- |
| Golden Image | AMI | The Golden Image is the AMI that will be used to create the instances associated to the private subnets |
| Golden Image Snapshot | Snapshot | The Golden Image Snapshot is created automatically during the process and not removed |
| Security Group | Security Group | The Security Group will allow SSH access to the Golden Image building instance from the local machine |

From the resources above, only the Security Group is automatically removed when the module is destroyed.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.3.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2.1 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Manifest_path"></a> [Manifest\_path](#input\_Manifest\_path) | Path to the Packer resulting manifest.json file | `string` | n/a | yes |
| <a name="input_Name"></a> [Name](#input\_Name) | Base name for the resources | `string` | n/a | yes |
| <a name="input_Tags"></a> [Tags](#input\_Tags) | Tags to apply to the resources | `map(string)` | `{}` | no |
| <a name="input_local_ip"></a> [local\_ip](#input\_local\_ip) | Local IP address to allow SSH access | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the builder instance | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Manifest"></a> [Manifest](#output\_Manifest) | n/a |



## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [null_resource.packer](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [http_http.local_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [local_file.manifest](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |


<!-- END_TF_DOCS -->