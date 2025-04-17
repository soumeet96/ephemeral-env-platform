output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = concat(
    [for subnet in aws_subnet.public_1 : subnet.id],
    [for subnet in aws_subnet.public_2 : subnet.id]
  )
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "security_group_id" {
  value = aws_security_group.ecs_service_sg.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}