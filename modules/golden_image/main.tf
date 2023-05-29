/***
  *
  * # Golden Image Module
  *
  * This module will create the Golden Image used by the instances associated to the private subnets.
  *
  * **Attention**: Sometimes the Golden Image creation process fails due to some Ubuntu update/upgrade/install errors.
  *     If this happens, you can try to run the process again and it will probably work.
  *
  * | Resource | Type | Description |
  * | --- | --- | --- |
  * | Golden Image | AMI | The Golden Image is the AMI that will be used to create the instances associated to the private subnets |
  * | Golden Image Snapshot | Snapshot | The Golden Image Snapshot is created automatically during the process and not removed |
  * | Security Group | Security Group | The Security Group will allow SSH access to the Golden Image building instance from the local machine |
  *
  * From the resources above, only the Security Group is automatically removed when the module is destroyed.
  *
  */

locals {
  get_local_ip      = var.local_ip != "" ? 0 : 1
  local_ip          = var.local_ip != "" ? var.local_ip : "${chomp(data.http.local_ip[0].response_body)}/32"
  vpc_id            = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.this.id
  public_subnet_ids = [for s in data.aws_subnets.public.ids : s]
}

/*********************************
 * DATA SOURCES
 *********************************/
// Identify the current AWS region
data "aws_region" "current" {}

// Identify VPC associated to the current project
data "aws_vpc" "this" {
  tags = {
    "Name" = var.Name
  }
}

// Identify the local public IP address
data "http" "local_ip" {
  count = local.get_local_ip

  url = "https://checkip.amazonaws.com/"

  method = "GET"

  request_headers = {
    "Content-Type" = "text/plain"
    "Accept"       = "text/plain"
  }
}

// Identify the public subnets associated to the current project
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

/*********************************
 * RESOURCES
 *********************************/

// Create SG to allow SSH access to the Golden Image building instance
resource "aws_security_group" "this" {
  name        = "${var.Name}-golden-image"
  description = "Allow SSH access to the Golden Image building instance"

  vpc_id = local.vpc_id

  ingress {
    description = "SSH access from the local IP address"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.local_ip]
  }

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { "Name" = "${var.Name}-golden-image" },
    var.Tags,
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }

}

// Create the Golden Image
resource "null_resource" "packer" {
  triggers = {
    ami_name = var.Name
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/packer"
    command     = <<_EOC_
packer build \
  -var "Name=${var.Name}" \
  -var "Manifest_path=${var.Manifest_path}" \
  -var "default_sg=${aws_security_group.this.id}" \
  -var "vpc_id=${local.vpc_id}" \
  -var "subnet_id=${local.public_subnet_ids[0]}" \
  golden_image.pkr.hcl
_EOC_
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "local_file" "manifest" {
  filename = var.Manifest_path

  depends_on = [null_resource.packer]
}
