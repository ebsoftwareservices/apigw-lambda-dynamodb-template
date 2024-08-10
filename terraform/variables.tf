# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "ap-southeast-2"
}

variable "apigw_name" {
  description = "name of the api gateway"
  type        = string
  default     = "apigw-http-lambda"

}

variable "apigw_log_retention" {
  description = "api gwy log retention in days"
  type        = number
  default     = 7
}
