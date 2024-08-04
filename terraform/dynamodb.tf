resource "aws_dynamodb_table" "table_foo" {
  name         = var.dynamodb_table_foo
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "year"
  range_key    = "foo"

  attribute {
    name = "year"
    type = "N"
  }

  attribute {
    name = "foo"
    type = "S"
  }
}

resource "aws_dynamodb_table" "table_bar" {
  name         = var.dynamodb_table_bar
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "year"
  range_key    = "bar"

  attribute {
    name = "year"
    type = "N"
  }

  attribute {
    name = "bar"
    type = "S"
  }
}
