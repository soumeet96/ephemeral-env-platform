resource "aws_subnet" "public_1" {
  count             = length(var.public_subnet_cidrs_1)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs_1[count.index]
  availability_zone = var.azs[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-1"
  }
}

resource "aws_subnet" "public_2" {
  count             = length(var.public_subnet_cidrs_2)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs_2[count.index]
  availability_zone = var.azs[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-2"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}