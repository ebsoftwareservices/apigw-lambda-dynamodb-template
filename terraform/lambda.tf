resource "aws_s3_bucket" "lambda_bucket" {
  bucket_prefix = var.s3_bucket_prefix
  force_destroy = true
}

data "archive_file" "lambda_zip_foo" {
  type = "zip"

  source_dir  = "${path.module}/../src/foo"
  output_path = "${path.module}/foo.zip"
}

resource "aws_s3_object" "foo" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "foo.zip"
  source = data.archive_file.lambda_zip_foo.output_path

  etag = filemd5(data.archive_file.lambda_zip_foo.output_path)
}

data "archive_file" "lambda_zip_bar" {
  type = "zip"

  source_dir  = "${path.module}/../src/bar"
  output_path = "${path.module}/bar.zip"
}

resource "aws_s3_object" "bar" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "bar.zip"
  source = data.archive_file.lambda_zip_bar.output_path

  etag = filemd5(data.archive_file.lambda_zip_bar.output_path)
}

//Define lambda function
resource "aws_lambda_function" "apigw_lambda_dynamodb_foo" {
  function_name = "${var.lambda_name_foo}-${random_string.random.id}"
  description   = "api gateway lambda example foo"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.foo.key

  runtime = "python3.8"
  handler = "index.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip_foo.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DDB_TABLE = var.dynamodb_table_foo
    }
  }
  depends_on = [aws_cloudwatch_log_group.lambda_logs_foo]

}

resource "aws_cloudwatch_log_group" "lambda_logs_foo" {
  name = "/aws/lambda/${var.lambda_name_foo}-${random_string.random.id}"

  retention_in_days = var.lambda_log_retention
}

resource "aws_lambda_function" "apigw_lambda_dynamodb_bar" {
  function_name = "${var.lambda_name_bar}-${random_string.random.id}"
  description   = "api gateway lambda example bar"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.bar.key

  runtime = "python3.8"
  handler = "index.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip_bar.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DDB_TABLE = var.dynamodb_table_bar
    }
  }
  depends_on = [aws_cloudwatch_log_group.lambda_logs_bar]

}

resource "aws_cloudwatch_log_group" "lambda_logs_bar" {
  name = "/aws/lambda/${var.lambda_name_bar}-${random_string.random.id}"

  retention_in_days = var.lambda_log_retention
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaDdbPost"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_role" {
  name = "lambda-tf-pattern-ddb-post"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/${var.dynamodb_table_foo}",
        "arn:aws:dynamodb:*:*:table/${var.dynamodb_table_bar}"
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
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_role.arn
}
