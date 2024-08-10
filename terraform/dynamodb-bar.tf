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
