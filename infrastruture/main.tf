provider "digitalocean" {
  token = var.do_token
}

provider "aws" {
  region     = "us-east-1"
}

data "digitalocean_kubernetes_cluster" "project_cluster" {
  name = module.k8s_cluster.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.project_cluster.endpoint
    token                  = data.digitalocean_kubernetes_cluster.project_cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.project_cluster.kube_config[0].cluster_ca_certificate
    )
  }
}

provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.project_cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.project_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
  data.digitalocean_kubernetes_cluster.project_cluster.kube_config[0].cluster_ca_certificate
  )
}

provider "kubectl" {
  host                   = data.digitalocean_kubernetes_cluster.project_cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.project_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
  data.digitalocean_kubernetes_cluster.project_cluster.kube_config[0].cluster_ca_certificate
  )
  load_config_file       = false
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "aws_route53_zone" "domain_zone" {
  name = var.domain_name
}

module "k8s_cluster" {
  source       = "./cluster"
  cluster_name = var.cluster_name
}

locals {
  ingress_annotations = {
    "kubernetes.io/ingress.class"    = "nginx"
    "cert-manager.io/cluster-issuer" = module.certificate_manager.cluster_issuer_name
  }
}
