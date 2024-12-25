# Fetch the VPC
data "aws_vpc" "ansible_vpc" {
  id = "vpc-0b1be6d8fbd694712"
}

# # Fetch the route table using subnet_id, if it exists
# data "aws_route_table" "ansible_vpc_rt" {
#   subnet_id = "subnet-0d410dd41581e1303"
# }

data "aws_route_table" "ansible_vpc_rt" {
  vpc_id = "vpc-0b1be6d8fbd694712"
}

# Resource: VPC Peering Connection
resource "aws_vpc_peering_connection" "ansible-vpc-peering" {
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

# Route: Add a route from the current VPC to the peer VPC
resource "aws_route" "peering-to-ansible-vpc" {
  route_table_id            = aws_route_table.terraform-public.id
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible-vpc-peering.id

  # Ensure the VPC peering connection exists before creating this route
  depends_on = [aws_vpc_peering_connection.ansible-vpc-peering]
}

# Route: Add a route from the peer VPC to the current VPC
resource "aws_route" "peering-from-ansible-vpc" {
  # Dynamically fetch route table ID if it exists, otherwise handle gracefully
  count = length([for rt in data.aws_route_table.ansible_vpc_rt : rt.id if rt.id != null])

  route_table_id            = data.aws_route_table.ansible_vpc_rt[count.index].id
  destination_cidr_block    = "10.37.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible-vpc-peering.id

  # Ensure the VPC peering connection exists before creating this route
  depends_on = [aws_vpc_peering_connection.ansible-vpc-peering]
}
