
data "aws_caller_identity" "current" {

}

data "aws_region" "current" {
  provider = aws
}

resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = var.s3_bucket
}

resource "aws_s3_bucket_acl" "tf_s3_bucket_acl" {
  bucket = aws_s3_bucket.tf_s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_s3_bucket_versioning" {
  bucket = aws_s3_bucket.tf_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
