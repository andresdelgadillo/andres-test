
resource "aws_dynamodb_table" "tf-dynamodb-table" {
  name         = var.config.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.config.dynamodb_table
  }
}