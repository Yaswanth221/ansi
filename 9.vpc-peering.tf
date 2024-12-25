# Fetch the VPC
data "aws_vpc" "ansible_vpc" {
  id = "vpc-0b1be6d8fbd694712"
}

# Fetch the default VPC (current VPC)
data "aws_vpc" "default_vpc" {
  id = aws_vpc.default.id
}

# Fetch the route table for the current VPC (by vpc_id and filter by tag Name)
data "aws_route_table" "terraform_public" {
  vpc_id = data.aws_vpc.default_vpc.id

  # Optional: Remove or update this filter if needed
  filter {
    name   = "tag:Name"
    values = ["public-route-table"] # Use the correct tag name from the AWS CLI output
  }
}

# Fetch the route table for the peer VPC (using the known route table ID)
data "aws_route_table" "ansible_vpc_rt" {
  route_table_id = "rtb-0c3d380cc4a1d7339" # Use the route table ID from the describe command
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
  route_table_id            = data.aws_route_table.terraform_public.id
  destination_cidr_block    = "172.31.0.0/16" # Adjust CIDR block as per peer VPC's CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible_vpc_peering.id

  depends_on = [aws_vpc_peering_connection.ansible_vpc_peering]
}

# Route: Add a route from the peer VPC to the current VPC
resource "aws_route" "peering_from_ansible_vpc" {
  route_table_id            = data.aws_route_table.ansible_vpc_rt.id
  destination_cidr_block    = "10.37.0.0/16" # Adjust CIDR block as per current VPC's CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible_vpc_peering.id

  depends_on = [aws_vpc_peering_connection.ansible_vpc_peering]
}
