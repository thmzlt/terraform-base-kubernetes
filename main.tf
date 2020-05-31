terraform {
  required_version = ">= 0.12.20"

  /*
  required_providers {
    google = {
      source  = "terraform-providers/terraform-provider-google"
      version = "3.23.0"
    }

    helm = {
      source  = "terraform-providers/terraform-provider-helm"
      version = "1.2.1"
    }

    kubectl = {
      source  = "gavinbunney/terraform-provider-kubectl"
      version = "1.4.2"
    }

    kubernetes = {
      source  = "terraform-providers/terraform-provider-kubernetes"
      version = "1.11.3"
    }
  }
  */
}

# Providers

provider "google" {
  credentials = file("credentials.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

provider "kubernetes" {
}

provider "kubectl" {
}

provider "helm" {
  version = "~> 1.1"
}

# Infrastructure Resources

resource "google_dns_managed_zone" "master" {
  name     = "master"
  dns_name = "${var.dns_zone}."
}

resource "google_compute_network" "master" {
  name                    = "master"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "master" {
  name          = "master"
  region        = var.region
  network       = google_compute_network.master.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_container_cluster" "master" {
  name               = "master"
  location           = var.zone
  min_master_version = var.k8s_version

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  provisioner "local-exec" {
    command = <<EOT

      gcloud container clusters get-credentials master --zone ${var.zone} --project ${var.project_id}
    EOT
  }
}

resource "google_container_node_pool" "master" {
  name       = "master"
  cluster    = google_container_cluster.master.name
  location   = var.zone
  version    = var.k8s_version
  node_count = 3

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    preemptible  = true
    machine_type = "g1-small"
    tags         = []

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Namespaces

resource "kubernetes_namespace" "master" {
  metadata {
    name = var.namespace
  }

  depends_on = [
    google_container_cluster.master,
    google_container_node_pool.master
  ]
}

locals {
  namespace = kubernetes_namespace.master.metadata[0].name
}

# Modules

module "cert_manager" {
  source    = "./modules/cert-manager"
  namespace = local.namespace

  helm_chart_version                      = "0.15.1"
  project_id                              = var.project_id
  dns_zone                                = var.dns_zone
  external_dns_service_account_secret     = module.external_dns.service_account_secret
  external_dns_service_account_secret_key = module.external_dns.service_account_secret_key
}

module "concourse" {
  source    = "./modules/concourse"
  namespace = "concourse"

  helm_chart_version = ""
}

module "external_dns" {
  source    = "./modules/external-dns"
  namespace = local.namespace

  helm_chart_version = "3.1.0"
  project_id         = var.project_id
  dns_zone           = google_dns_managed_zone.master.dns_name
}

module "ingress_nginx" {
  source    = "./modules/ingress-nginx"
  namespace = local.namespace

  helm_chart_version = "2.3.0"
}

module "test_service" {
  source    = "./modules/test-service"
  namespace = local.namespace

  hostname = "test-service.${var.dns_zone}"
}
