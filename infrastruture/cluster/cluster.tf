terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

data "digitalocean_kubernetes_versions" "cluster_version" {
  version_prefix = "1.21."
}

resource "digitalocean_kubernetes_cluster" "project_cluster" {
  name    = var.cluster_name
  region  = "nyc1"
  version = data.digitalocean_kubernetes_versions.cluster_version.latest_version

  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-4vcpu-8gb"
    node_count = 3
  }
}