# Fetch the peer VPC (Ansible VPC)
data "aws_vpc" "ansible_vpc" {
  id = "vpc-0b1be6d8fbd694712" # Replace with actual peer VPC ID
}

# Fetch the default VPC (the current VPC)
data "aws_vpc" "default_vpc" {
  id = "vpc-xxxxxxxx" # Replace with the actual default VPC ID
}

# Resource: VPC Peering Connection
resource "aws_vpc_peering_connection" "ansible_vpc_peering" {
  peer_vpc_id = data.aws_vpc.ansible_vpc.id
  vpc_id      = data.aws_vpc.default_vpc.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "Ansible-${var.vpc_name}-Peering"
  }
}

# Route: Add a route from the current VPC to the peer VPC
resource "aws_route" "peering_to_ansible_vpc" {
  count                     = length(data.aws_route_table.terraform_public.routes) > 0 ? 0 : 1
  route_table_id            = data.aws_route_table.terraform_public.id
  destination_cidr_block    = "10.37.0.0/16" # Route to peer VPC CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible_vpc_peering.id

  depends_on = [aws_vpc_peering_connection.ansible_vpc_peering]
}

# Route: Add a route from the peer VPC to the current VPC
resource "aws_route" "peering_from_ansible_vpc" {
  count                     = length(data.aws_route_table.ansible_vpc_rt.routes) > 0 ? 0 : 1
  route_table_id            = data.aws_route_table.ansible_vpc_rt.id
  destination_cidr_block    = "172.31.0.0/16" # Route to current VPC CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible_vpc_peering.id

  depends_on = [aws_vpc_peering_connection.ansible_vpc_peering]
}
