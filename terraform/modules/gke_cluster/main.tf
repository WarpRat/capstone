resource "google_container_cluster" "this" {
  name     = "${var.name}-cluster"
  location = "${var.location}"

  remove_default_node_pool = true
  initial_node_count       = 1

  # Intentionally setting these as empty to disable basic auth.
  master_auth {
    username = ""
    password = ""
  }

  addons_config {
    kubernetes_dashboard {
      disabled = "${var.dashboard_enabled ? "false" : "true" }"
    }
  }
}

resource "google_container_node_pool" "this" {
  name               = "${var.name}-node-pool"
  location           = "${var.location}"
  cluster            = "${google_container_cluster.this.name}"
  node_count         = 1
  monitoring_service = "${var.monitoring}"

  autoscaling {
    min_node_count = "${var.min_node_count}"
    max_node_count = "${var.max_node_count}"
  }

  node_config {
    preemptible  = "${var.preemptible}"
    machine_type = "${var.machine_type}"
    disk_size_gb = "${var.disk_size}"
    disk_type    = "${var.disk_type}"
    labels       = "${var.node_labels}"
    image_type   = "${var.image_type}"

    metadata {
      disable-legacy-endpoints = "true"
    }

    # TODO: Convert to a concatinated list of local and variable oauth scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_repair  = "${var.auto_repair}"
    auto_upgrade = "${var.auto_upgrade}"
  }
}
