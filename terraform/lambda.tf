resource "aws_iam_role" "lambda_role" {
  name = "terraform-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "terraform-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.state_bucket}"
      },
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.state_bucket}/env/*"
      }
    ]
  })
}

resource "aws_lambda_function" "state_cleanup" {
  function_name = "terraform-state-cleanup"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      STATE_BUCKET = var.state_bucket
      TTL_HOURS    = var.ttl_hours
      GITHUB_TOKEN  = var.github_token
      GITHUB_REPO   = "soumeet96/ephemeral-env-platform"
      GITHUB_OWNER    = "soumeet96"
    }
  }

  timeout = 300
}

resource "aws_cloudwatch_event_rule" "every_hour" {
  name        = "run-lambda-every-hour"
  description = "Triggers Lambda function every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_lambda_permission" "allow_event_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.state_cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_hour.arn
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.every_hour.name
  arn  = aws_lambda_function.state_cleanup.arn
}

resource "aws_iam_role" "manual_trigger_lambda" {
  name = "manual-trigger-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "manual_trigger_logging" {
  role       = aws_iam_role.manual_trigger_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "manual_trigger" {
  function_name = "github_trigger"
  handler       = "github_trigger.lambda_handler"
  runtime       = "python3.8"

  filename      = "github_trigger.zip"
  source_code_hash = filebase64sha256("github_trigger.zip")

  environment {
    variables = {
      GITHUB_TOKEN = var.github_token
    }
  }

  role = aws_iam_role.manual_trigger_lambda.arn
}

resource "aws_apigatewayv2_api" "manual_trigger" {
  name          = "manual-trigger-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "manual_trigger" {
  api_id                 = aws_apigatewayv2_api.manual_trigger.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.manual_trigger.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "manual_trigger" {
  api_id    = aws_apigatewayv2_api.manual_trigger.id
  route_key = "GET /trigger"
  target    = "integrations/${aws_apigatewayv2_integration.manual_trigger.id}"
}

resource "aws_apigatewayv2_stage" "manual_trigger" {
  api_id      = aws_apigatewayv2_api.manual_trigger.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.manual_trigger.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.manual_trigger.execution_arn}/*/*"
}