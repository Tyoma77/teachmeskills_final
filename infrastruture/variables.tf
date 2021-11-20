variable "do_token" {
  description = "token to the DO account"
  type        = string
}

/* variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
} */

variable "cluster_name" {
  description = "Name of K8S cluster"
  default     = "project-cluster"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  default     = "k8sproject.ml"
  type        = string
}

variable "es_admin_name" {
  description = "Es for logs admin name"
  default     = "admin"
  type        = string
}
