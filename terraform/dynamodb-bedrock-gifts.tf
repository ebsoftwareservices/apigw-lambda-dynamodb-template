module "dynamodb_table_bedrock_gifts" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name         = "bedrock-gifts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]
}
