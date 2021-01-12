
resource "aws_cloudfront_distribution" "cloudfront" {

  is_ipv6_enabled = var.cf_ipv6_enabled
  http_version    = "http2"

  enabled = true

  origin {
    origin_id   = "origin-${var.fqdn}"
    domain_name = aws_s3_bucket.main.website_endpoint

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/
    # DeveloperGuide/distribution-web-values-specify.html
    custom_origin_config {
      # "HTTP Only: CloudFront uses only HTTP to access the origin."
      # "Important: If your origin is an Amazon S3 bucket configured
      # as a website endpoint, you must choose this option. Amazon S3
      # doesn't support HTTPS connections for website endpoints."
      origin_protocol_policy = "http-only"

      http_port  = "80"
      https_port = "443"

      # TODO: given the origin_protocol_policy set to `http-only`,
      # not sure what this does...
      # "If the origin is an Amazon S3 bucket, CloudFront always uses TLSv1.2."
      origin_ssl_protocols = ["TLSv1.2"]
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

  aliases = concat([var.fqdn], var.aliases)

  price_class = var.cloudfront_price_class



  dynamic "default_cache_behavior" {
    for_each = [for k, v in var.cache_behavior : v if k == "default"]
    iterator = i

    content {
      target_origin_id       = i.value["target_origin_id"]
      viewer_protocol_policy = i.value["viewer_protocol_policy"]

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
          event_type   = l.key
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
          event_type   = l.key
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
