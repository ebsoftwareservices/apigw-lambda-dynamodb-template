module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name               = var.apigw_name
  description        = "foo api gateway"
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

  # Authorizer(s)
  authorizers = {
    "cognito" = {
      authorizer_type  = "JWT"
      identity_sources = ["$request.header.Authorization"]
      name             = var.authorizers["name"]
      jwt_configuration = {
        audience = var.authorizers["audience"]
        issuer   = var.authorizers["issuer"]
      }
    }
  }

  # Routes & Integration(s)
  routes = {
    "PUT /users/me/preferences/ebdx" = {
      authorization_type = "JWT"
      authorizer_key     = "cognito"

      integration = {
        type = "AWS_PROXY"
        uri  = module.lambda_get_organization.lambda_function_invoke_arn
      }
    }
    "GET /clients/{id}" = {
      integration = {
        type = "AWS_PROXY"
        uri  = module.lambda_get_organization.lambda_function_invoke_arn
      }
    }
  }
}
