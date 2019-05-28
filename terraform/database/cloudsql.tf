resource "google_sql_database_instance" "gitlabsql" {
  provider = "google-beta"

  name             = "gitlab-cloudsql"
  region           = "${var.region}"
  database_version = "POSTGRES_9_6"

  #This is defined in network.tf in this folder
  depends_on = [
    "google_service_networking_connection.cloudsql_service",
  ]

  #Private network is defined in network.tf in this folder
  settings {
    tier = "db-custom-4-15360"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "${data.google_compute_network.default.self_link}"
    }
  }
}

resource "google_sql_user" "gitlab_user" {
  name     = "gitlab"
  instance = "${google_sql_database_instance.gitlabsql.name}"
  password = "${var.gitlab_db_pass}"

  depends_on = [
    "google_sql_database_instance.gitlabsql",
  ]
}

resource "google_sql_database" "gitlab_db" {
  name     = "gitlab-prod"
  instance = "${google_sql_database_instance.gitlabsql.name}"

  depends_on = [
    "google_sql_user.gitlab_user",
  ]
}
