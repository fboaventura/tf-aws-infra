/**
 *
 * Variables
 *
 * Variables used on the `instances` module.
 *
 */
# Required variables
# ------------------
# The following variables are required, and if not set, the module will fail.


variable "Name" {
  description = "Base name for the resources"
  type        = string
}

variable "Image" {
  description = "Data from the Golden Image generated Manifest"
}

variable "Network" {
  description = "Data from the Network module"
}


# Optional variables
# ------------------
# The following variables are optional, and if not set, the default values
# will be used.

variable "Tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "local_ip" {
  description = "Local IP address to allow SSH access to the instances"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID to deploy the builder instance"
  type        = string
  default     = ""
}


/***************************************
 * Bastion Host Instance configuration
 ***************************************/
# AMI version to use for the instances filters
variable "ami_filter_name" {
  description = "Bastion Host: AMI name to use on the filter"
  type        = list(string)
  default     = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

variable "ami_filter_architecture" {
  description = "Bastion Host: AMI architecture to use on the filter"
  type        = list(string)
  default     = ["amd64"]
}

variable "ami_filter_virtualization_type" {
  description = "Bastion Host: AMI virtualization type to use on the filter"
  type        = list(string)
  default     = ["hvm"]
}

variable "ami_filter_owners" {
  description = "Bastion Host: AMI owners to use on the filter"
  type        = list(string)
  default     = ["099720109477"]
}
