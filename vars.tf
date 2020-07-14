# CloudFront

variable "fqdn" {
  type        = string
  description = "The FQDN of the website and also name of the S3 bucket"
}

variable "cf_ipv6_enabled" {
  default = true
  type    = bool
}

variable "single_page_application" {
  default = false
  type    = bool
}

variable "spa_error_response_code" {
  type        = string
  description = "Response code to send on 404 for a single page application"
  default     = "200"
}

variable "aliases" {
  type        = list(string)
  description = "Any other domain aliases to add to the CloudFront distribution"
  default     = []
}

variable "cloudfront_price_class" {
  type        = string
  description = "PriceClass for CloudFront distribution. One of PriceClass_All, PriceClass_200, PriceClass_100."
  default     = "PriceClass_100"
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ARN of the certificate covering the fqdn and its apex?"
}

variable "web_acl_id" {
  type        = string
  description = "WAF Web ACL ID to attach to the CloudFront distribution, optional"
  default     = ""
}

### S3

variable "force_destroy" {
  type        = string
  description = "The force_destroy argument of the S3 bucket"
  default     = "false"
}

variable "allowed_ips" {
  type        = list(string)
  description = "A list of IPs that can access the S3 bucket directly"
  default     = []
}

variable "refer_secret" {
  type        = string
  description = "Authenticate S3 to CloudFront"
  default     = "Pinning-s3-bucket"
}

variable "routing_rules" {
  type        = string
  description = "Routing rules for the S3 bucket"
  default     = ""
}

variable "index_document" {
  type        = string
  description = "HTML to show at root"
  default     = "index.html"
}

variable "error_document" {
  type        = string
  description = "HTML to show on 404"
  default     = "404.html"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}
