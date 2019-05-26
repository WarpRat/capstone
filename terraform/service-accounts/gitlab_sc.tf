module "gitlab_sa" {
  source       = "../modules/service_account_project"
  account_id   = "gitlab-storage-sa"
  display_name = "Gitlab storage service account"
  roles        = ["roles/service.admin"]
}

output "gitlab_sa_pk" {
  value = "${module.gitlab_sa.private_key}"
}
