module "dynamodb_table_foo" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name         = "bedrock-helloworld"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
}
