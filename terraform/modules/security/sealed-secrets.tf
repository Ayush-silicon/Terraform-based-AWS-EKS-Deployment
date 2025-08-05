resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets-controller"
  repository = "https://bitnami-labs.github.io/sealed-secrets" // replace it with valid repo name...
  chart      = "sealed-secrets"
  namespace  = "kube-system"
  version    = "2.14.1"

  values = [
    yamlencode({
      fullnameOverride = "sealed-secrets-controller"
      
      resources = {
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }

      metrics = {
        serviceMonitor = {
          enabled = true
        }
      }
    })
  ]
}
