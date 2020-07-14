output "s3_bucket_id" {
  value = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.main.arn
}

output "cf_domain_name" {
  value = aws_cloudfront_distribution.cloudfront.domain_name
}

output "cf_hosted_zone_id" {
  value = aws_cloudfront_distribution.cloudfront.hosted_zone_id
}

output "cf_distribution_id" {
  value = aws_cloudfront_distribution.cloudfront.id
}
