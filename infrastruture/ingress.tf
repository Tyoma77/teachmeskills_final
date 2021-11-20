module "certificate_manager" {
  source                = "terraform-iaac/cert-manager/kubernetes"
  cluster_issuer_email  = "1032578@gmail.com"
  cluster_issuer_server = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "helm_release" "nginx_ingress_controller" {
  name       = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  wait       = true
}

data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name = "${helm_release.nginx_ingress_controller.name}-nginx-ingress-controller"
  }
  depends_on = [helm_release.nginx_ingress_controller]
}
