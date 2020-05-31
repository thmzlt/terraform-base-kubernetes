resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = var.helm_chart_version
  namespace  = var.namespace

  values = [
    <<YAML
      installCRDs: true
    YAML
  ]
}

resource "kubectl_manifest" "cert_manager_certificate" {
  yaml_body = templatefile("${path.module}/certificate.template.yaml", {
    namespace = var.namespace
    dns_zone  = var.dns_zone
  })

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "kubectl_manifest" "cert_manager_issuer" {
  yaml_body = templatefile("${path.module}/issuer.template.yaml", {
    namespace                               = var.namespace
    project_id                              = var.project_id
    email                                   = "acme@${var.dns_zone}"
    external_dns_service_account_secret     = var.external_dns_service_account_secret
    external_dns_service_account_secret_key = var.external_dns_service_account_secret_key
  })

  depends_on = [
    helm_release.cert_manager
  ]
}
