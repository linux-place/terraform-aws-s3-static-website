
resource "aws_cloudfront_distribution" "cloudfront" {
  is_ipv6_enabled = var.cf_ipv6_enabled
  http_version    = "http2"

  enabled = true

  logging_config {
    include_cookies = var.include_cookies
    bucket          = var.logging_bucket
    prefix          = var.logging_bucket_dir_prefix
  }

  origin {
    origin_id   = var.origin_id
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/
    # DeveloperGuide/distribution-web-values-specify.html
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_user.cloudfront_access_identity_path
    }

    # s3_origin_config is not compatible with S3 website hosting, if this
    # is used, /news/index.html will not resolve as /news/.
    # https://www.reddit.com/r/aws/comments/6o8f89/can_you_force_cloudfront_only_access_while_using/
    # s3_origin_config {
    #   origin_access_identity = "${aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path}"
    # }
    # Instead, we use a secret to authenticate CF requests to S3 policy.
    # Not the best, but...
    custom_header {
      name  = "User-Agent"
      value = var.refer_secret
    }
  }

  default_root_object = var.index_document

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "300"
    response_code         = var.single_page_application ? var.spa_error_response_code : var.error_response_code
    response_page_path    = "/${var.single_page_application ? var.index_document : var.error_document}"
  }
  dynamic custom_error_response {
    for_each = var.override_forbbiden == true ? toset([1]) : toset([0])
    content {
      error_code            = "403"
      error_caching_min_ttl = "300"
      response_code         = var.single_page_application ? var.spa_error_response_code : var.error_response_code
      response_page_path    = "/${var.single_page_application ? var.index_document : var.error_document}"
    }
  }


  aliases = concat([var.fqdn], var.aliases)

  price_class = var.cloudfront_price_class



  dynamic "default_cache_behavior" {
    for_each = [for k, v in var.cache_behavior : v if k == "default"]
    iterator = i

    content {
      target_origin_id       = i.value["target_origin_id"]
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      #cache_policy_id           = lookup(i.value, "cache_policy_id", null)
      allowed_methods           = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods            = lookup(i.value, "cached_methods", ["GET", "HEAD"])
      compress                  = lookup(i.value, "compress", null)
      field_level_encryption_id = lookup(i.value, "field_level_encryption_id", null)
      smooth_streaming          = lookup(i.value, "smooth_streaming", null)
      trusted_signers           = lookup(i.value, "trusted_signers", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      forwarded_values {
        query_string            = lookup(i.value, "query_string", false)
        query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
        headers                 = lookup(i.value, "headers", null)

        cookies {
          forward           = lookup(i.value, "cookies_forward", "none")
          whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.value.event_type
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = [for k, v in var.cache_behavior : v if k != "default"]
    iterator = i

    content {
      path_pattern           = i.value["path_pattern"]
      target_origin_id       = i.value["target_origin_id"]
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

      #cache_policy_id           = lookup(i.value, "cache_policy_id", null)
      allowed_methods           = lookup(i.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods            = lookup(i.value, "cached_methods", ["GET", "HEAD"])
      compress                  = lookup(i.value, "compress", null)
      field_level_encryption_id = lookup(i.value, "field_level_encryption_id", null)
      smooth_streaming          = lookup(i.value, "smooth_streaming", null)
      trusted_signers           = lookup(i.value, "trusted_signers", null)

      min_ttl     = lookup(i.value, "min_ttl", null)
      default_ttl = lookup(i.value, "default_ttl", null)
      max_ttl     = lookup(i.value, "max_ttl", null)

      forwarded_values {
        query_string            = lookup(i.value, "query_string", false)
        query_string_cache_keys = lookup(i.value, "query_string_cache_keys", [])
        headers                 = lookup(i.value, "headers", null)

        cookies {
          forward           = lookup(i.value, "cookies_forward", "none")
          whitelisted_names = lookup(i.value, "cookies_whitelisted_names", null)
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(i.value, "lambda_function_association", [])
        iterator = l

        content {
          event_type   = l.value.event_type
          lambda_arn   = l.value.lambda_arn
          include_body = lookup(l.value, "include_body", null)
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.ssl_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  web_acl_id = var.web_acl_id
}

# User to connect to Private S3 
resource "aws_cloudfront_origin_access_identity" "cloudfront_user" {}