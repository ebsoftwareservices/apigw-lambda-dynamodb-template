# Output value definitions

output "apigwy_url" {
  description = "URL for API Gateway stage"

  value = module.api_gateway.stage_invoke_url
}

