data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_global_address" "cloudsql_ips" {
  provider      = "google-beta"
  name          = "cloudsql-ips"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = "${data.google_compute_network.default.self_link}"
}

resource "google_service_networking_connection" "cloudsql_service" {
  provider                = "google-beta"
  network                 = "${data.google_compute_network.default.self_link}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.cloudsql_ips.name}"]
}
