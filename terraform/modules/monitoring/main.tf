resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "55.5.0"

  create_namespace = true

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp3"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "50Gi"
                  }
                }
              }
            }
          }
          retention = "30d"
        }
      }

      grafana = {
        adminPassword = var.grafana_admin_password
        
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          }
        }

        persistence = {
          enabled = true
          size = "10Gi"
          storageClassName = "gp3"
        }

        dashboardProviders = {
          "dashboardproviders.yaml" = {
            apiVersion = 1
            providers = [
              {
                name = "default"
                orgId = 1
                folder = ""
                type = "file"
                disableDeletion = false
                editable = true
                options = {
                  path = "/var/lib/grafana/dashboards/default"
                }
              }
            ]
          }
        }

        dashboards = {
          default = {
            "kubernetes-cluster-monitoring" = {
              gnetId = 315
              revision = 3
              datasource = "Prometheus"
            }
            "kubernetes-node-exporter" = {
              gnetId = 1860
              revision = 27
              datasource = "Prometheus"
            }
          }
        }
      }

      alertmanager = {
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp3"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "10Gi"
                  }
                }
              }
            }
          }
        }
      }
    })
  ]
}