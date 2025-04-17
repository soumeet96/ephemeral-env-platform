resource "aws_eip" "nat" {
  tags = {
    Name = "${var.name}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1[0].id
  tags = {
    Name = "${var.name}-nat-gw"
  }
  depends_on = [aws_internet_gateway.main]
}