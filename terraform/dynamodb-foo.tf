module "dynamodb_table_foo" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name         = "foo"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "foo"

  attributes = [
    {
      name = "foo"
      type = "S"
    }
  ]
}
