region   = "us-west-2"
vpc_cidr = "172.31.0.0/16"
public_subnets = [
  {
    az   = "us-west-2a"
    cidr = "172.31.48.0/22"
  },
  {
    az   = "us-west-2b"
    cidr = "172.31.52.0/22"
  },
  {
    az   = "us-west-2c"
    cidr = "172.31.56.0/22"
  }
]
private_subnets = [
  {
    az   = "us-west-2a"
    cidr = "172.31.0.0/20"
  },
  {
    az   = "us-west-2b"
    cidr = "172.31.16.0/20"
  },
  {
    az   = "us-west-2c"
    cidr = "172.31.32.0/20"
  }
]
domain = "ortega.tech"
