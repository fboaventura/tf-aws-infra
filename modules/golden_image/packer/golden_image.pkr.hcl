packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
  required_version = ">= 1.7"
}

# Variables
variable "Name" {
  description = "Name of the Golden Image on AWS"
  type        = string
}

variable "Manifest_path" {
  description = "Path to the manifest file"
  type        = string
  default     = "manifest.json"
}

variable "default_sg" {
  description = "Local IP address"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = null
}

# Get the latest Ubuntu 22.04 AMI
data "amazon-ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
  }
}

# Locals
locals {
  source_ami_id   = data.amazon-ami.ubuntu.id
  source_ami_name = data.amazon-ami.ubuntu.name
}

# Configure the Amazon AMI builder
source "amazon-ebs" "golden_image" {
  ami_name              = var.Name
  ami_description       = "Golden Image for ${var.Name}"
  instance_type         = "t2.micro"
  force_deregister      = true
  force_delete_snapshot = true
  encrypt_boot          = true
  communicator          = "ssh"
  ssh_username          = "ubuntu"
  ssh_timeout           = "90m"
  security_group_id     = var.default_sg
  vpc_id                = var.vpc_id
  subnet_id             = var.subnet_id

  source_ami = local.source_ami_id

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 10
    volume_type           = "gp3"
    throughput            = 200
    delete_on_termination = true
  }

  tags = {
    Name          = var.Name
    OS_Version    = "Ubuntu 22.04"
    Release       = "Jammy Jellyfish"
    Base_AMI      = local.source_ami_id
    Base_AMI_Name = local.source_ami_name
  }
  run_tags = {
    Name = "Packer Builder - Golden Image"
  }
}

build {
  name    = "Golden Image"
  sources = ["source.amazon-ebs.golden_image"]

  provisioner "shell" {
    script = "scripts/install.sh"
  }

  post-processor "manifest" {
    output     = var.Manifest_path
    strip_path = true
  }
}
