resource "aws_s3_bucket" "main" {
  provider = aws.main
  bucket   = var.fqdn
  acl      = "private"
  policy   = data.aws_iam_policy_document.bucket_policy.json

  website {
    index_document = var.index_document
    error_document = var.error_document
    routing_rules  = var.routing_rules
  }

  force_destroy = var.force_destroy

  logging {
    target_bucket = var.logging_bucket_s3
    target_prefix = var.logging_bucket_dir_prefix_s3
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.fqdn
    },
  )
}

# Block all access outside
resource "aws_s3_bucket_public_access_block" "s3_block_access" {
  bucket = aws_s3_bucket.main.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "bucket_policy" {
  provider = aws.main

  # Allow only CloudFront with OAI set igual below
  statement {
    sid = "AllowCFOriginAccessIdentity"
    actions   = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${var.fqdn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_user.iam_arn]
    }
  }
}

