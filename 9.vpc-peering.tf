# Declare data source for the default VPC
data "aws_vpc" "ansible_vpc" {
  id = "vpc-0b2d9527a95fa9f71" # Replace with the actual ID of your default VPC
}

# Declare data source for the Ansible VPC
data "aws_route_table" "ansible_vpc_rt" {
  subnet_id = "subnet-0db61983f3b7099dc" # Replace with the actual ID of your Ansible VPC
}

# Resource: VPC Peering Connection
resource "aws_vpc_peering_connection" "ansible_vpc_peering" {
  peer_vpc_id = data.aws_vpc.ansible_vpc.id
  vpc_id      = aws_vpc.default.id
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

# Route: Add a route from the default VPC to the Ansible VPC
resource "aws_route" "peering_to_ansible_vpc" {
  route_table_id            = "aws_route_table.terraform-public.id" # Route table ID of the Default VPC
  destination_cidr_block    = "10.40.0.0/16"                        # Route to Default VPC CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible-vpc-peering.id

  depends_on = [aws_vpc_peering_connection.ansible_vpc_peering]
}

# Route: Add a route from the Ansible VPC to the Default VPC

resource "aws_route" "peering_from_ansible_vpc" {
  route_table_id            = "data.aws_route_table.ansible_vpc_rt.id" # Route table ID of the Ansible VPC
  destination_cidr_block    = "10.37.0.0/16"                           # Route to Ansible VPC CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible-vpc-peering.id

  # depends_on = [aws_vpc_peering_connection.ansible_vpc_peering]
}
