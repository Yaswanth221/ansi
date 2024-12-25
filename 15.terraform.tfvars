aws_region           = "ap-northeast-1"
vpc_cidr             = "10.37.0.0/16"
vpc_name             = "Ansible-Vpc"
key_name             = "pack"
public_subnet_cidrs  = ["10.37.1.0/24", "10.37.2.0/24", "10.37.3.0/24"]          #List
private_subnet_cidrs = ["10.37.10.0/24", "10.37.20.0/24", "10.37.30.0/24"]       #List
azs                  = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"] #List
environment          = "production"
instance_type = {
  development = "t2.small"
  testing     = "t2.small"
  production  = "t2.small"
}
amis = {
  ap-northeast-1 = "ami-0b2cd2a95639e0e5b" # Canonical, Ubuntu, 20.04 LTS, amd64 focal image
  ap-northeast-2 = "ami-049788618f07e189d" # Canonical, Ubuntu, 20.04 LTS, amd64 focal image
}
projid    = "PHOENIX-123"
imagename = "ami-0b2cd2a95639e0e5b"
