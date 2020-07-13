variable "fqdn" {
  type        = string
  description = "The FQDN of the website and also name of the S3 bucket"
}

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
