output "load_balancer_dns" {
  value = aws_lb.dev.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.dev.arn
}

output "app_url" {
  value = "http://${aws_route53_record.app.name}"
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}