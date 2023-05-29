# Find the latest Ubuntu AMI ID for the given region

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ami_filter_name
  }

  filter {
    name   = "virtualization-type"
    values = var.ami_filter_virtualization_type
  }

  owners = var.ami_filter_owners
}

data "aws_ami" "golden_image" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.Name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}
