module "lambda_foo" {
  source                            = "terraform-aws-modules/lambda/aws"
  function_name                     = "foo-${random_string.random.id}"
  runtime                           = "python3.12"
  handler                           = "index.lambda_handler"
  use_existing_cloudwatch_log_group = false
  source_path = [
    "${path.module}/../src/foo",
  ]
  trigger_on_package_timestamp = false

  environment_variables = {
    DDB_TABLE = "foo"
  }

  attach_policy_json = true
  policy_json        = <<_EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:*"
        ],
        "Resource": [
          "${module.dynamodb_table_foo.dynamodb_table_arn}"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  }
  _EOF
}

resource "aws_lambda_permission" "apigw_foo" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_foo.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
  depends_on    = [module.api_gateway, module.dynamodb_table_foo]
}
