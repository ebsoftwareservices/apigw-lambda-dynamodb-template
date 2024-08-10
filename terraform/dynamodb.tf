module "dynamodb_table_foo" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name         = "foo"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "year"
  range_key    = "foo"
  attributes = [
    {
      name = "year"
      type = "N"
      }, {
      name = "foo"
      type = "S"
    }
  ]
}

module "dynamodb_table_bar" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name         = "bar"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "year"
  range_key    = "bar"
  attributes = [
    {
      name = "year"
      type = "N"
      }, {
      name = "bar"
      type = "S"
    }
  ]
}
