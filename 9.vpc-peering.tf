# Declare data source for the default VPC
data "aws_vpc" "default_vpc" {
  # Fetch default VPC by using its ID
  id = "vpc-08d5ab01a1c3d56a1" # Replace with the actual ID of your default VPC
}

# Declare data source for the Ansible VPC
data "aws_vpc" "ansible_vpc" {
  # Fetch the Ansible VPC by using its ID
  id = "vpc-0b1be6d8fbd694712" # Replace with the actual ID of your Ansible VPC
}

# Fetch the route table for the current VPC (public route table)
data "aws_route_table" "terraform_public" {
  vpc_id = data.aws_vpc.default_vpc.id # Use default VPC ID from the data source
}

# Fetch the route table for the peer VPC (Ansible VPC route table)
data "aws_route_table" "ansible_vpc_rt" {
  vpc_id = data.aws_vpc.ansible_vpc.id # Use Ansible VPC ID from the data source
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
  destination_cidr_block    = "10.37.0.0/16" # Route to peer VPC CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible_vpc_peering.id

  depends_on = [aws_vpc_peering_connection.ansible_vpc_peering]
}

# Route: Add a route from the peer VPC to the current VPC
resource "aws_route" "peering_from_ansible_vpc" {
  route_table_id            = data.aws_route_table.ansible_vpc_rt.id
  destination_cidr_block    = "172.31.0.0/16" # Route to current VPC CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible_vpc_peering.id

  depends_on = [aws_vpc_peering_connection.ansible_vpc_peering]
}
