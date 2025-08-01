resource "helm_release" "kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/kubecost"
  chart      = "cost-analyzer"
  namespace  = "kubecost"
  version    = "2.0.2"

  create_namespace = true

  values = [
    yamlencode({
      global = {
        prometheus = {
          enabled = false
          fqdn = "http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090"
        }
        grafana = {
          enabled = false
          domainName = var.grafana_domain
        }
      }

      kubecostProductConfigs = {
        clusterName = var.cluster_name
      }

      persistentVolume = {
        enabled = true
        size = "32Gi"
        storageClass = "gp3"
      }

      ingress = {
        enabled = true
        className = "alb"
        annotations = {
          "alb.ingress.kubernetes.io/scheme" = "internet-facing"
          "alb.ingress.kubernetes.io/target-type" = "ip"
        }
        hosts = [
          {
            host = var.kubecost_domain
            paths = [
              {
                path = "/"
                pathType = "Prefix"
              }
            ]
          }
        ]
      }
    })
  ]

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}