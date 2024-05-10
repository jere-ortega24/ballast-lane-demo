resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    "kubernetes.io/cluster/demo" = "shared"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "public-internet-gateway-${var.region}"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index].cidr
  availability_zone       = var.public_subnets[count.index].az
  map_public_ip_on_launch = false

  tags = {
    Name                         = "public-${var.public_subnets[count.index].az}"
    "kubernetes.io/cluster/demo" = "shared"
    "kubernetes.io/role/elb"     = "1"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnets[count.index].cidr
  availability_zone       = var.private_subnets[count.index].az
  map_public_ip_on_launch = false

  tags = {
    Name                              = "private-${var.private_subnets[count.index].az}"
    "kubernetes.io/cluster/demo"      = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "this" {
  count = length(var.public_subnets)

  domain = "vpc"

  tags = {
    Name = "eip-nat-gateway-${var.public_subnets[count.index].az}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nat-gateway-${var.public_subnets[count.index].az}"
  }
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = {
    Name = "route-table-main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "route-table-${var.region}-public"
  }
}

resource "aws_route" "default_public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(aws_nat_gateway.this)

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "route-table-${var.public_subnets[count.index].az}"
  }
}

resource "aws_route" "default_private" {
  count = length(aws_nat_gateway.this)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
