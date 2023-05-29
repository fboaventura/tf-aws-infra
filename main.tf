/********************************************
 *
 * # AWS Infrastructure
 *
 * This is the main Terraform file for the AWS infrastructure.
 *
 * This module will call the following modules:
 *
 *  - Network
 *  - Golden Image
 *  - Instances
 *
 */

/********************************************
 * Terraform Module: Local variables
 ********************************************/

locals {
  get_local_ip = var.local_ip != "" ? 0 : 1
  local_ip     = var.local_ip != "" ? var.local_ip : "${chomp(data.http.local_ip.response_body)}/32"
}

/********************************************
 * Terraform Module: Data Sources
 ********************************************/

// Identify the local public IP address
data "http" "local_ip" {
  url = "https://checkip.amazonaws.com/"

  method = "GET"

  request_headers = {
    "Content-Type" = "text/plain"
    "Accept"       = "text/plain"
  }
}

/********************************************
 * Terraform Module: Network
 ********************************************/

module "network" {
  source = "./modules/network"

  N_Subnets    = var.N_Subnets
  Name         = var.Name
  Network_CIDR = var.Network_CIDR
  Tags         = var.Tags

}

/********************************************
 * Terraform Module: Golden Image
 ********************************************/

module "golden_image" {
  source = "./modules/golden_image"

  Name          = var.Name
  Tags          = var.Tags
  Manifest_path = abspath(var.Manifest_path)

  local_ip = local.local_ip
  vpc_id   = module.network.Network.vpc_id

  depends_on = [module.network]
}

/********************************************
 * Terraform Module: Instances
 ********************************************/

module "instances" {
  source = "./modules/instances"

  Name    = var.Name
  Tags    = var.Tags
  Image   = module.golden_image.Manifest
  Network = module.network.Network

  local_ip = local.local_ip

  depends_on = [module.network, module.golden_image]
}

resource "local_file" "network" {
  filename = "./resource/network.out"
  content  = module.network.Network
}

resource "local_file" "golden_image" {
  filename = "./resource/golden_image.out"
  content  = module.golden_image.Manifest
}
