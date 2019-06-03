resource "google_service_account" "this" {
  account_id   = "${var.account_id}"
  display_name = "${var.display_name == "default" ? var.account_id : var.display_name}"
}

# We need to wait a few seconds after the service account is created to try to attach an ACL
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "echo $MESSAGE && sleep 5"

    environment = {
      MESSAGE = "Waiting for the service account to finish creating before attaching roles."
    }
  }

  triggers {
    "sc" = "${google_service_account.this.unique_id}"
  }
}

resource "google_project_iam_member" "this" {
  depends_on = ["null_resource.delay"]
  count      = "${length(var.roles)}"
  role       = "${element(var.roles, count.index)}"
  member     = "serviceAccount:${google_service_account.this.email}"
}

resource "google_service_account_key" "this" {
  service_account_id = "${google_service_account.this.name}"
}
