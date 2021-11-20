resource "aws_route53_record" "argocd_domain" {
  name    = "argocd"
  type    = "A"
  ttl     = 300
  zone_id = data.aws_route53_zone.domain_zone.id
  records = [data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress.0.ip]
}

resource "aws_route53_record" "grafana_domain" {
  name    = "grafana"
  type    = "A"
  ttl     = 300
  zone_id = data.aws_route53_zone.domain_zone.id
  records = [data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress.0.ip]
}

resource "aws_route53_record" "prometheus_domain" {
  name    = "prometheus"
  type    = "A"
  ttl     = 300
  zone_id = data.aws_route53_zone.domain_zone.id
  records = [data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress.0.ip]
}

resource "aws_route53_record" "sonarqube_domain" {
  name    = "sonarqube"
  type    = "A"
  ttl     = 300
  zone_id = data.aws_route53_zone.domain_zone.id
  records = [data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress.0.ip]
}

resource "aws_route53_record" "app_domain" {
  name    = "app"
  type    = "A"
  ttl     = 300
  zone_id = data.aws_route53_zone.domain_zone.id
  records = [data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress.0.ip]
}
