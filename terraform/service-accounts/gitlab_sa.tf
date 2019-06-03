module "gitlab_sa" {
  source       = "../modules/service_account_project"
  account_id   = "gitlab-storage-sa"
  display_name = "Gitlab storage service account"
  roles        = ["roles/storage.admin"]
}

# Disable for now - try local exec instead
#output "gitlab_sa_pk" {
#  value = "${module.gitlab_sa.private_key}"
#}

resource "null_resource" "write_key" {
  provisioner "local-exec" {
    command = "cd $HOME/.capstone_secure && gcloud iam service-accounts keys screate --iam-account ${module.gitlab_sa.email} gcs-key.json"
  }

  triggers {
    "sa" = "${module.gitlab_sa.email}"
  }
}
