resource "aws_apigatewayv2_api" "startServer" {
  name          = "start-${var.game_name}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "startServer" {
  api_id              = aws_apigatewayv2_api.startServer.id
  credentials_arn     = aws_iam_role.example.arn

  integration_type    = "AWS_PROXY"
  connection_type     = "INTERNET"
  integration_method  = "GET"
  integration_uri     = aws_lambda_function.startServer.invoke_arn
}

data "archive_file" "lambdaFile" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "startServer" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_handler"
  role          = aws_iam_role.api_role.arn
  handler       = "index.test"

  source_code_hash = data.archive_file.lambdaFile.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      INSTANCE_ID = "${var.instance_id}"
    }
  }
}

resource "aws_iam_role" "api_role" {
    name = var.game_name
    assume_role_policy = jsonencode(
        {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
        }
    )
}