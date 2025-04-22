output "app_url" {
  value = module.service.app_url
}

output "manual_trigger_api_url" {
  description = "Invoke URL for manual trigger API"
  value       = "${aws_apigatewayv2_stage.manual_trigger.invoke_url}/trigger"
}