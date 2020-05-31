output "reference" {
  value = ""

  depends_on = [
    # The name isn't important, we only want to create an explicit dependency
    helm_release.cert_manager.metadata.name
  ]
}
