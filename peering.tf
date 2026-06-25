
# 1. Establish the VPC Peering Connection

resource "aws_vpc_peering_connection" "default" {
    count = var.is_peering_required ? 1 : 0
    peer_vpc_id   = data.aws_vpc.default.id  # acceptor
    vpc_id        = aws_vpc.main.id # requestor
    auto_accept = true

    requester {
      allow_remote_vpc_dns_resolution = true
    }

    accepter {
      allow_remote_vpc_dns_resolution = true
    }

    tags = merge(
        var.vpc_peering_tags,
        local.common_tags,
        {
            Name = "${local.common_name}-peering"
        }
    )
}

# 2. Route from Requester VPC to Accepter VPC

resource "aws_route" "public_to_accepter" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

resource "aws_route" "private_to_accepter" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}


resource "aws_route" "database_to_accepter" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# 3. Route from Accepter VPC back to Requester VPC

resource "aws_route" "accepter_to_requester" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}