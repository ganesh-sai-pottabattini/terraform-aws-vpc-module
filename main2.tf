# In this code, i am creating two identical set of subnets for each tier. so 
# total 1 VPC, 1 IGw, 6 subnets in 2 avaialability zones [ each az has 3 subnets - public, private, database ]
# 5 route tables [ 1- public , 2 - private , 2- database ], 
# 5 route table associations [ 1 public rt to 2 public subnets , 2 rt to 2 private subnets respectively ,2 rt to 2 databases subnets respectively ]
# 2 elastic ips
# 2 nat gateways for both public subnets
# 5 routes created and added to 5 route tables [ 1 public rt to 2 public subnets , 2 rt to 2 private subnets respectively ,2 rt to 2 databases subnets respectively ]
# vpc peering from dev to test

# resource "aws_vpc" "main" {
#   cidr_block       = var.vpc_cidr
#   instance_tenancy = "default"
#   enable_dns_hostnames = true
# 
#   tags = merge(
#     var.vpc_tags,
#     local.common_tags
#   )
# }
# 
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.main.id
# 
#   tags = merge(
#     local.common_tags,
#     var.igw_tags,
#     {
#       Name = "${local.common_name}-igw"
#     }
#   )
# }
# 
# resource "aws_subnet" "public" {
#     count = length(var.public_subnet_cidr)
#     vpc_id     = aws_vpc.main.id
#     cidr_block = var.public_subnet_cidr[count.index]
#     availability_zone = local.azs_names[count.index]
#     map_public_ip_on_launch = true
# 
#     tags = merge(
#         var.public_subnet_tags,
#         local.common_tags,
#         {
#             Name = "${local.common_name}-public-${split("-" , local.azs_names[count.index])[2]}"
#         }
#   )
# }
# 
# resource "aws_subnet" "private" {
#     count = length(var.private_subnet_cidr)
#     vpc_id     = aws_vpc.main.id
#     cidr_block = var.private_subnet_cidr[count.index]
#     availability_zone = local.azs_names[count.index]
#     map_public_ip_on_launch = false
# 
#     tags = merge(
#         var.private_subnet_tags,
#         local.common_tags,
#         {
#             Name = "${local.common_name}-private-${split("-" , local.azs_names[count.index])[2]}"
#         }
#   )
# }
# 
# resource "aws_subnet" "database" {
#     count = length(var.database_subnet_cidr)
#     vpc_id     = aws_vpc.main.id
#     cidr_block = var.database_subnet_cidr[count.index]
#     availability_zone = local.azs_names[count.index]
#     map_public_ip_on_launch = false
# 
#     tags = merge(
#         var.database_subnet_tags,
#         local.common_tags,
#         {
#             Name = "${local.common_name}-database-${split("-" , local.azs_names[count.index])[2]}" 
#                  # "${local.common_name}-database-${split("-",local.az_names[count.index])[2]}"
#         }
#   )
# }
# 
# resource "aws_route_table" "public" {
#   #count = length(var.public_subnet_cidr)
#   vpc_id = aws_vpc.main.id
# 
#   tags = merge (
#     var.public_route_table_tags,
#     local.common_tags,
#     {
#         Name = "${local.common_name}-public"
#     }
#     )
# }
# 
# resource "aws_route_table" "private" {
#   count = length(var.private_subnet_cidr)
#   vpc_id = aws_vpc.main.id
# 
#   tags = merge (
#     var.private_route_table_tags,
#     local.common_tags,
#     {
#         Name = "${local.common_name}-private-${split("-" , local.azs_names[count.index])[2]}"
#     }
#     )
# }
# 
# resource "aws_route_table" "database" {
#   count = length(var.database_subnet_cidr)
#   vpc_id = aws_vpc.main.id
# 
#   tags = merge (
#     var.database_route_table_tags,
#     local.common_tags,
#     {
#         Name = "${local.common_name}-database-${split("-" , local.azs_names[count.index])[2]}"
#     }
#     )
# }
# 
# resource "aws_route_table_association" "public" {
#   count = length(var.public_subnet_cidr)
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }
# 
# resource "aws_route_table_association" "private" {
#   count = length(var.private_subnet_cidr)
#   route_table_id = aws_route_table.private[count.index].id
#   subnet_id      = aws_subnet.private[count.index].id
# 
# }
# 
# resource "aws_route_table_association" "database" {
#   count = length(var.database_subnet_cidr)
#   route_table_id = aws_route_table.database[count.index].id
#   subnet_id      = aws_subnet.database[count.index].id
# }
# 
# resource "aws_eip" "nat" {
#   count = length(var.public_subnet_cidr)
#   domain   = "vpc"
# 
#   tags = merge(
#     var.eip_tags,
#     local.common_tags,
#     {
#         Name = "${local.common_name}-eip"
#     }
#   )
# }
# 
# resource "aws_nat_gateway" "main" {
#   count = length(var.public_subnet_cidr)
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = aws_subnet.public[count.index].id
# 
#   tags = merge(
#     var.nat_gateway_tags,
#     local.common_tags,
#     {
#         Name = "${local.common_name}-nat-${count.index + 1}"
#     }
#   )
# 
#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.igw]
# }
# 
# resource "aws_route" "public" {
#   route_table_id            = aws_route_table.public.id
#   destination_cidr_block    = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.igw.id
# }
# 
# resource "aws_route" "private" {
#   count = length(var.private_subnet_cidr)
#   route_table_id = aws_route_table.private[count.index].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id = aws_nat_gateway.main[count.index].id
# }
# 
# resource "aws_route" "database" {
#     count = length(var.database_subnet_cidr)
#     route_table_id = aws_route_table.database[count.index].id
#     destination_cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main[count.index].id
# }