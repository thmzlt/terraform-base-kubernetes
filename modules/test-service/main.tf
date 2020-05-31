resource "kubernetes_ingress" "test_service" {
  metadata {
    name      = "test-service"
    namespace = var.namespace

    annotations = {
      "cert-manager.io/issuer" = "letsencrypt-prod"
    }
  }

  spec {
    rule {
      host = var.hostname

      http {
        path {
          backend {
            service_name = "test-service"
            service_port = 80
          }
        }
      }
    }

    tls {
      hosts       = [var.hostname]
      secret_name = "cert-manager-certificate-secret"
    }
  }
}

resource "kubernetes_service" "test_service" {
  metadata {
    name      = "test-service"
    namespace = var.namespace
  }
  spec {
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app = "test-service"
    }
  }
}

resource "kubernetes_deployment" "test_service" {
  metadata {
    name      = "test-service"
    namespace = var.namespace
  }
  spec {
    selector {
      match_labels = { app = "test-service" }
    }
    template {
      metadata {
        labels = { app = "test-service" }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
