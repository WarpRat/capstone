data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_global_address" "cloudsql_ips" {
  name          = "cloudsql_ips"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = "${data.google_compute_network.default.self_link}"
}

resource "google_service_networking connection" "cloudsql_service" {
  network                 = "${data.google_compute_network.default.self_link}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.cloudsql_ips.name}"]
}
