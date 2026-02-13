# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-central-1"
}

variable "apigw_name" {
  description = "name of the api gateway"
  type        = string
  default     = "bedrock-api-gateway"

}

variable "apigw_log_retention" {
  description = "api gwy log retention in days"
  type        = number
  default     = 7
}

variable "authorizers" {
  description = "(optional) api gateway authorizers"
}
