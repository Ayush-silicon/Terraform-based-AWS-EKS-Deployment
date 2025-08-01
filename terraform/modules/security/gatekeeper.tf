resource "helm_release" "gatekeeper" {
  name       = "gatekeeper"
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  namespace  = "gatekeeper-system"
  version    = "3.14.0"

  create_namespace = true

  values = [
    yamlencode({
      replicas = 3
      
      audit = {
        replicas = 1
      }

      controller = {
        replicas = 3
      }

      podSecurityPolicy = {
        enabled = true
      }

      resources = {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }
    })
  ]
}

# Security Policies
resource "kubectl_manifest" "require_resources" {
  yaml_body = yamlencode({
    apiVersion = "templates.gatekeeper.sh/v1beta1"
    kind       = "ConstraintTemplate"
    metadata = {
      name = "k8srequiredresources"
    }
    spec = {
      crd = {
        spec = {
          names = {
            kind = "K8sRequiredResources"
          }
          validation = {
            openAPIV3Schema = {
              type = "object"
              properties = {
                limits = {
                  type = "array"
                  items = {
                    type = "string"
                  }
                }
              }
            }
          }
        }
      }
      targets = [
        {
          target = "admission.k8s.gatekeeper.sh"
          rego = <<-EOT
            package k8srequiredresources
            
            violation[{"msg": msg}] {
              container := input.review.object.spec.containers[_]
              not container.resources.limits.cpu
              msg := "Container missing CPU limit"
            }
            
            violation[{"msg": msg}] {
              container := input.review.object.spec.containers[_]
              not container.resources.limits.memory
              msg := "Container missing memory limit"
            }
          EOT
        }
      ]
    }
  })

  depends_on = [helm_release.gatekeeper]
}