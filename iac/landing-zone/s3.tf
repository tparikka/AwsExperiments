# s3.tf

# The S3 bucket where the current state will be stored. Replace firstname and lastname with the name of the developer
resource "aws_s3_bucket" "tfstate" {
  bucket = "awsexperiments-backend-tfstate-firstname-lastname"
}