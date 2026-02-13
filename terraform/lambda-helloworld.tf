module "lambda_bedrock_helloworld" {
  source                            = "terraform-aws-modules/lambda/aws"
  function_name                     = "bedrock-helloworld"
  runtime                           = "nodejs24.x"
  handler                           = "index.handler"
  use_existing_cloudwatch_log_group = false
  layers                            = [module.lambda_layer_bedrock_helloworld.lambda_layer_arn]
  source_path = [
    {
      path = "${path.module}/../src/helloworld"
      commands = [
        ":zip"
      ]
      patterns = [
        "!node_modules/.*"
      ]
    }
  ]

  trigger_on_package_timestamp = true
  recreate_missing_package     = true
  ignore_source_code_hash      = true
  artifacts_dir                = "${path.root}/builds"

  environment_variables = {
    BEDROCK_VARIABLE = "Hello world!"
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

resource "aws_lambda_permission" "bedrock-api-gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_bedrock_helloworld.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
  depends_on = [
    module.api_gateway,
    module.dynamodb_table_foo
  ]
}

module "lambda_layer_bedrock_helloworld" {
  source                  = "terraform-aws-modules/lambda/aws"
  create_function         = false
  create_layer            = true
  layer_name              = "lambda-foo-layer"
  runtime                 = "nodejs24.x"
  ignore_source_code_hash = true
  artifacts_dir           = "${path.root}/builds"
  source_path = [
    {
      path = "${path.module}/../src/helloworld"
      commands = [
        "npm install --production",
        ":zip"
      ]
      patterns = [
        "!.*",
        "node_modules/.*"
      ]
    }
  ]
}
