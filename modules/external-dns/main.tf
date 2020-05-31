locals {
  service_account_secret     = "external-dns-service-account"
  service_account_secret_key = "credentials.json"
}

resource "google_service_account" "external_dns" {
  account_id   = "external-dns"
  display_name = "External DNS"
}

resource "google_service_account_key" "external_dns" {
  service_account_id = google_service_account.external_dns.name
}

resource "google_project_iam_binding" "external_dns" {
  project = var.project_id
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.external_dns.email}"
  ]
}

resource "kubernetes_secret" "external_dns_credentials" {
  metadata {
    name      = local.service_account_secret
    namespace = var.namespace
  }

  data = {
    "${local.service_account_secret_key}" = base64decode(google_service_account_key.external_dns.private_key)
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  version    = var.helm_chart_version
  namespace  = var.namespace

  values = [
    <<YAML
      provider: google
      google:
        project: ${var.project_id}
        serviceAccountSecret: ${local.service_account_secret}
        serviceAccountSecretKey: ${local.service_account_secret_key}
    YAML
  ]

  depends_on = [
    kubernetes_secret.external_dns_credentials
  ]
}
