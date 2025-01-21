resource "aws_security_group" "allow_specific" {
  name        = "allow_specific"
  description = "Allow specific inbound traffic"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Ensure this is needed; otherwise, restrict to specific IPs.
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.1.1.0/24"] # Broadened subnet range if needed.
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.2.1.0/24"] # Broadened subnet range if needed.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
