module "gitlab-cluster" {
  source       = "modules/gke_cluster"
  name         = "capstone-project"
  location     = "${var.zone}"
  machine_type = "n1-standard-4"
}
