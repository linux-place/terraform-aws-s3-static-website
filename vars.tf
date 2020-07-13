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
  description = "A secret string to authenticate CF requests to S3"
  default     = "123-VERY-SECRET-123"
}

variable "routing_rules" {
  type        = string
  description = "Routing rules for the S3 bucket"
  default     = ""
}
