resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.51.6"

  create_namespace = true

  values = [
    yamlencode({
      global = {
        domain = var.argocd_domain
      }
      
      configs = {
        params = {
          "server.insecure" = true
        }
      }

      server = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          }
        }
        
        ingress = {
          enabled = true
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/scheme" = "internet-facing"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
          hosts = [var.argocd_domain]
        }
      }

      controller = {
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    
    labels = {
      name = "argocd"
    }
  }
}