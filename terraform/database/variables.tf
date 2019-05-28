variable "project" {
  description = "The GCP project to launch resources in"
}

variable "region" {
  description = "The region to launch resources in"
}

variable "zone" {
  description = "The zone to launch resources in"
}

variable "gitlab_db_pass" {
  description = "Password for the gitlab user to access the postgres database"
}
