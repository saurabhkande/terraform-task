
# S3 bucket

resource "aws_s3_bucket" "public_bucket" {
  bucket = "ssk94221"
}

resource "aws_s3_bucket_ownership_controls" "s3-ownership" {
  bucket = aws_s3_bucket.public_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-access" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3-ownership,
    aws_s3_bucket_public_access_block.s3-access,
  ]

  bucket = aws_s3_bucket.public_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "s3-versioning" {
  bucket = aws_s3_bucket.public_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}
