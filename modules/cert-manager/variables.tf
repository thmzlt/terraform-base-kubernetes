variable "helm_chart_version" {
  type = string
}

variable "namespace" {
  type = string
}

variable "project_id" {
  type = string
}

variable "dns_zone" {
  type = string
}

variable "external_dns_service_account_secret" {
  type = string
}

variable "external_dns_service_account_secret_key" {
  type = string
}
