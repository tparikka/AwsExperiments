resource "aws_dynamodb_table" "lock_table" {
  name     = "tf-lock"
  read_capacity = 20
  write_capacity = 20
  billing_mode = "PROVISIONED"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}