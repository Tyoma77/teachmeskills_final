terraform {
  backend "s3" {
    bucket         = "teachmeskills-final"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
    kubectl      = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }
  }
}