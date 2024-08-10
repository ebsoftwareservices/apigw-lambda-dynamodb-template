module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name               = "${var.apigw_name}-${random_string.random.id}"
  description        = "My awesome HTTP API Gateway"
  protocol_type      = "HTTP"
  create_domain_name = false

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Access logs
  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = var.apigw_log_retention
    format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }

  # Routes & Integration(s)
  routes = {
    "POST /foo" = {
      integration = {
        uri                    = module.lambda_foo.lambda_function_invoke_arn
        type                   = "AWS_PROXY"
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    }

    "GET /foo" = {
      integration = {
        type = "AWS_PROXY"
        uri  = module.lambda_foo.lambda_function_invoke_arn
      }
    }
  }
}
