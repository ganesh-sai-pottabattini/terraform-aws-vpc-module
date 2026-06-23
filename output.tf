output "azs_info" {
  value = slice(data.aws_availability_zones.availability.names, 0 , 2)
}