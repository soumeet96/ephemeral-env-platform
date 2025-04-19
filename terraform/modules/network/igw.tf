resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-public-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_1" {
  count          = length(aws_subnet.public_1)
  subnet_id      = aws_subnet.public_1[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  count          = length(aws_subnet.public_2)
  subnet_id      = aws_subnet.public_2[count.index].id
  route_table_id = aws_route_table.public.id
}