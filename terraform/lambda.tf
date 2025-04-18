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
