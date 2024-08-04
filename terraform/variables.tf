# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "ap-southeast-2"
}

variable "s3_bucket_prefix" {
  description = "S3 bucket prefix"
  type        = string
  default     = "apigw-lambda-dynamodb"

}

variable "dynamodb_table_foo" {
  description = "name of the dynamodb table"
  type        = string
  default     = "foo"

}

variable "lambda_name_foo" {
  description = "name of the lambda function"
  type        = string
  default     = "foo"

}
variable "dynamodb_table_bar" {
  description = "name of the dynamodb table"
  type        = string
  default     = "bar"

}

variable "lambda_name_bar" {
  description = "name of the lambda function"
  type        = string
  default     = "bar"

}

variable "apigw_name" {
  description = "name of the api gateway"
  type        = string
  default     = "apigw-http-lambda"

}

variable "lambda_log_retention" {
  description = "lambda log retention in days"
  type        = number
  default     = 7
}

variable "apigw_log_retention" {
  description = "api gwy log retention in days"
  type        = number
  default     = 7
}
