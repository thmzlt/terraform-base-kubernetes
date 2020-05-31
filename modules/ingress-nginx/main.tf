terraform {
  required_version = ">= 0.12"
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = var.helm_chart_version
  namespace  = var.namespace
}
