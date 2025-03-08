module "lambda_foo" {
  source                            = "terraform-aws-modules/lambda/aws"
  function_name                     = "lambda-foo"
  runtime                           = "nodejs20.x"
  handler                           = "index.handler"
  use_existing_cloudwatch_log_group = false
  layers                            = [module.lambda_layer_foo.lambda_layer_arn]
  source_path = [
    {
      path = "${path.module}/../src/foo"
      commands = [
        "npm install",
        ":zip"
      ]
      patterns = [
        "!node_modules/.*"
      ]
    }
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
  depends_on = [
    module.api_gateway,
    module.dynamodb_table_foo
  ]
}

module "lambda_layer_foo" {
  source          = "terraform-aws-modules/lambda/aws"
  create_function = false
  create_layer    = true
  layer_name      = "lambda-foo-layer"
  runtime         = "nodejs20.x"
  source_path = [
    {
      path = "${path.module}/../src/foo"
      commands = [
        "npm install",
        ":zip"
      ]
      patterns = [
        "node_modules/.*"
      ]
    }
  ]
  hash_extra = "73D9A0E6-6486-4CD5-9165-2D99A67D2D76"
}
