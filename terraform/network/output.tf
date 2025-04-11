# Add output variables
output "vpc_id" {
  value = module.project-network.vpc_id
}

output "public_subnet_ids" {
  value = module.project-network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.project-network.private_subnet_ids
}