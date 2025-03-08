# Output value definitions

output "apigwy_url" {
  description = "URL for API Gateway stage"

  value = module.api_gateway.stage_invoke_url
}

output "lambda_layer_foo" {
  description = "URL for Lambda Layer"

  value = module.lambda_layer_foo
}
