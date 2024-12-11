# dynamodb.tf

# The DynamoDB table where lock state will be stored
resource "aws_dynamodb_table" "lock_table" {
  name     = "tf-lock"
  read_capacity = 20
  write_capacity = 20
  billing_mode = "PROVISIONED"
  hash_key = "LockID" # hash_key refers to the Partition Key of the table
  attribute {
    name = "LockID"
    type = "S"
  }
}