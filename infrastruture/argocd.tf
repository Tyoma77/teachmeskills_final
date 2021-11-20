resource "helm_release" "argo-cd" {
  chart            = "argo-cd"
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = "argocd"
  create_namespace = true
  values           = [
    yamlencode({
      server = {
        ingress = {
          enabled     = true
          annotations = merge(local.ingress_annotations, {
            "kubernetes.io/tls-acme" : "true",
            "nginx.ingress.kubernetes.io/ssl-passthrough" : "true",
            "nginx.ingress.kubernetes.io/backend-protocol" : "HTTPS"
          })
          hosts       = ["argocd.k8sproject.ml"]
          tls         = [
            {
              hosts      = ["argocd.k8sproject.ml"]
              secretName = "argo-tls"
            }
          ]
        }
      }
    })
  ]
}
