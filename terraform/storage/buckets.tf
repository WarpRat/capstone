resource "google_storage_bucket" "gitlab-buckets" {
  count = "${length(var.buckets)}"
  name  = "${var.project}-${element(var.buckets, count.index)}"
}
