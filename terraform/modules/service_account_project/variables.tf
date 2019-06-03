variable "account_id" {
  description = "(Required) The ID to use for the service account. Must be valid for use in an email address. (Not a full email address, GCP will build that)"
}

variable "roles" {
  description = "(Required) A list of roles to bind to the service account. At least one role is required."
  type        = "list"
}

variable "display_name" {
  description = "(Optional) A more descriptive display name to use for the service account, if this isn't specified it will default to using the account_id"
  default     = "default"
}
