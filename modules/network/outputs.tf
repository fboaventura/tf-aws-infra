/**
 *
 * Outputs
 *
 */

// Information related to all the created subnets
output "Network" {
  description = "Information related to all the created resources"
  value = {
    "count_subnets_total"        = var.N_Subnets
    "count_subnets_public"       = local.N_public_subnets
    "count_subnets_private"      = local.N_private_subnets
    "vpc_id"                     = aws_vpc.this.id
    "vpc_cidr"                   = aws_vpc.this.cidr_block
    "private_subnet_ids"         = [for v in data.aws_subnets.private.ids : v]
    "public_subnet_ids"          = [for v in data.aws_subnets.public.ids : v]
    "private_routing_table_arn"  = aws_route_table.private.arn
    "private_routing_table_id"   = aws_route_table.private.id
    "public_routing_table_arn"   = aws_route_table.public.arn
    "public_routing_table_id"    = aws_route_table.public.id
    "internet_gateway_arn"       = aws_internet_gateway.this.arn
    "internet_gateway_id"        = aws_internet_gateway.this.id
    "nat_gateway_allocation_id"  = aws_nat_gateway.this.allocation_id
    "nat_gateway_association_id" = aws_nat_gateway.this.association_id
    "nat_gateway_id"             = aws_nat_gateway.this.id
    "nat_gateway_private_ip"     = aws_nat_gateway.this.private_ip
    "nat_gateway_public_ip"      = aws_nat_gateway.this.public_ip
    "subnets_info" = { for k, v in data.aws_subnet.info : k => {
      "id"                      = v.id
      "cidr_block"              = v.cidr_block
      "availability_zone"       = v.availability_zone
      "availability_zone_id"    = v.availability_zone_id
      "arn"                     = v.arn
      "state"                   = v.state
      "vpc_id"                  = v.vpc_id
      "map_public_ip_on_launch" = v.map_public_ip_on_launch
      "default_for_az"          = v.default_for_az
      "owner_id"                = v.owner_id
      }
    }
  }
}
