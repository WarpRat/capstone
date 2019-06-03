output "public_key" {
  value = "${google_service_account_key.this.public_key}"
}

output "private_key" {
  value = "${google_service_account_key.this.private_key}"
}

output "email" {
  value = "${google_service_account.this.email}"
}
