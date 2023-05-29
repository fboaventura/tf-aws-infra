/**
 *
 * # Variables
 *
 * Variables used on the `network` module.
 *
 */
# Required variables
# ------------------
# The following variables are required, and if not set, the module will fail.

variable "Network_CIDR" {
  description = "The network IP address configuration on CIDR format"
  type        = string
}

variable "N_Subnets" {
  description = "The number of subnets to create"
  type        = number

  validation {
    condition     = var.N_Subnets > 2 && var.N_Subnets < 6
    error_message = "The number of subnets must be between 2 and 6"
  }
}

variable "Name" {
  description = "Base name for the resources"
  type        = string
}

variable "Tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}



# Optional variables
# ------------------
# The following variables are optional, and if not set, the default values
# will be used.
