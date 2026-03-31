# modules/applications/variables.tf
#
# Input variables for the applications module.
#
# engineering_group_id has no default — it MUST be passed from the root
# module. Terraform will error if you forget. This enforces the dependency
# between the groups and applications modules.

variable "engineering_group_id" {
  description = "Okta group ID for Engineering — the app will be assigned to this group"
  type        = string
}

variable "app_label" {
  description = "Display name for the OIDC application"
  type        = string
  default     = "Internal Dashboard"
}
