#retrieve keys from secret manager

data "aws_secretsmanager_secret" "datadog_secrets" {
  arn = var.datadog_secret_manager_arn
}

#retrieve current version of secret

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.datadog_secrets.id
}

#namespace to install data dog
resource "kubernetes_namespace" "datadog" {
count = var.datadog_enabled ? 1 : 0
  metadata {
    name = var.datadog_namespace
  }
}

#helm chart for datadog agent
resource "helm_release" "datadog_agent" {
count = var.datadog_enabled ? 1 : 0

  name       = "datadog-agent"
  chart      = "datadog"
  repository = "https://helm.datadoghq.com"
  version    = "2.10.1"
  namespace  = "default" #sets namespace to install agent

#   namespace  = kubernetes_namespace.datadog.id #sets namespace to install agent

  set_sensitive {
    name  = "datadog.apiKey"
    # value = var.datadog_api_key
    value = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["datadog_api_key"]

  }

  set {
    name  = "datadog.logs.enabled"
    value = true
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = true
  }

  set {
    name  = "datadog.leaderElection"
    value = true
  }

  set {
    name  = "datadog.collectEvents"
    value = true
  }

  set {
    name  = "clusterAgent.enabled"
    value = true
  }

  set {
    name  = "clusterAgent.metricsProvider.enabled"
    value = true
  }

  set {
    name  = "networkMonitoring.enabled"
    value = true
  }

  set {
    name  = "systemProbe.enableTCPQueueLength"
    value = true
  }

  set {
    name  = "systemProbe.enableOOMKill"
    value = true
  }

  set {
    name  = "securityAgent.runtime.enabled"
    value = true
  }

  set {
      name  = "datadog.hostVolumeMountPropagation"
      value = "HostToContainer"
  }

  depends_on = [
    kubernetes_namespace.datadog
  ]
}


# creating metric alert with databog provider 


provider "datadog" {
  # api_key = var.datadog_api_key
  # app_key = var.datadog_app_key
  api_key = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["datadog_api_key"]
  app_key = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["datadog_app_key"]
}

resource "datadog_monitor" "app" {
count = var.datadog_enabled ? 1 : 0
  name               = "App Pod Health"
  type               = "metric alert"
  message            = "Kubernetes Pods are not in an optimal health state. Notify: @operator @chainomi.gmail.com"
  escalation_message = "Please investigate the Kubernetes Pods, @operator"

# add the name of the image example below was for an image called "app"
# we are setting an alert when the max number of containers running image "app" is less than zero
# zero is the alert threshold
  query = "max(last_1m):sum:docker.containers.running{short_image:app} <= 0"

#monitor threshold notes, 
#ok is the value for healthy
# warning is used when close to the alert threshold
# critical is used when the pods go to zero and triggers and alert
  monitor_thresholds {
    ok       = 1
    warning  = 0.5
    critical = 0
  }

  notify_no_data = true

  tags = ["app:app", "env:dev"]
}


#health check
resource "datadog_synthetics_test" "app" {
count = var.datadog_enabled ? 1 : 0
  type    = "api"
  subtype = "http"

  request_definition {
    method = "GET"
    # enter endpoint below
    url    = "https://wordpress.chainomi.link"
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }

  locations = ["aws:${var.region}"]
  options_list {
    tick_every          = 900
    min_location_failed = 1
  }

  name    = "Beacon API Check"
  message = "Oh no! Light from the Beacon app is no longer shining!"
  #enter tags for datadog see example below
  tags    = ["app:app", "env:dev"]

  status = "live"
}


resource "datadog_dashboard" "app" {
count = var.datadog_enabled ? 1 : 0

  title        = "app service dashboard"
  description  = "A Datadog Dashboard for the app deployment"
  layout_type  = "ordered"
  is_read_only = true


  widget {
    hostmap_definition {
      no_group_hosts  = true
      no_metric_hosts = true
      node_type       = "container"
      title           = "Kubernetes Pods"

      request {
        fill {
            #enter full image name under as value for image_name
          q = "avg:process.stat.container.cpu.total_pct{short_image:app} by {host}"
        }
      }

      style {
        palette      = "hostmap_blues"
        palette_flip = false
      }
    }
  }

  widget {
    timeseries_definition {
      show_legend = false
      title       = "CPU Utilization"

      request {
        display_type = "line"
        #enter full image name under as value for image_name
        q            = "top(avg:docker.cpu.usage{short_image:app} by {docker_image,container_id}, 10, 'mean', 'desc')"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      yaxis {
        include_zero = true
        max          = "auto"
        min          = "auto"
        scale        = "linear"
      }
    }
  }

  widget {
    alert_graph_definition {
      # alert_id = datadog_monitor.app.id
      alert_id = datadog_monitor.app[count.index].id 
      title    = "Kubernetes Node CPU"
      viz_type = "timeseries"
    }
  }

  widget {
    hostmap_definition {
      no_group_hosts  = true
      no_metric_hosts = true
      node_type       = "host"
      title           = "Kubernetes Nodes"

      request {
        fill {
          q = "avg:system.cpu.user{*} by {host}"
        }
      }

      style {
        palette      = "hostmap_blues"
        palette_flip = false
      }
    }
  }

  widget {
    timeseries_definition {
      show_legend = false
      title       = "Memory Utilization"
      request {
        display_type = "line"
        #enter full image name under as value for image_name
        q            = "top(avg:docker.mem.in_use{short_image:app} by {container_name}, 10, 'mean', 'desc')"

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }
      yaxis {
        include_zero = true
        max          = "auto"
        min          = "auto"
        scale        = "linear"
      }
    }
  }
}
