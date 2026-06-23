locals {
  common_tags = {
    project = var.project
    environmet = var.environment
    Terraform = true
    Name = local.common_name
  }
  common_name = "${var.project}-${var.environment}"
  azs_names = slice(data.aws_availability_zones.availability.names, 0 , 2) # here 2 is exlcusive
  #az_names  = slice(data.aws_availability_zones.available.names, 0, 2) # here 2 is exlcusive
}