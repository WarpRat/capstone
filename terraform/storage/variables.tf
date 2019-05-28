variable "project" {
  description = "The GCP project to launch resources in"
}

variable "region" {
  description = "The region to launch resources in"
}

variable "zone" {
  description = "The zone to launch resources in"
}

variable "buckets" {
  description = "A list of buckets to create for gitlab"
  type        = "list"
}
