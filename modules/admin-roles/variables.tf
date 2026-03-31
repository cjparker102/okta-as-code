# modules/admin-roles/variables.tf
#
# Input variables for the custom admin role module.
#
# The permissions list defines exactly what this role can do — nothing more.
# This is the principle of least privilege in action.

variable "it_admin_group_id" {
  description = "Okta group ID for IT staff — receives the custom admin role"
  type        = string
}

variable "okta_org_name" {
  description = "Okta org subdomain — needed to construct resource set URNs"
  type        = string
}

variable "okta_base_url" {
  description = "Okta base URL — needed to construct resource set URNs"
  type        = string
}

variable "role_label" {
  description = "Display name for the custom admin role"
  type        = string
  default     = "IT Help Desk Admin"
}

variable "role_description" {
  description = "Description explaining the role's scope and purpose"
  type        = string
  default     = "Least-privilege admin role for IT help desk — can manage users and groups but cannot modify security policies, create API tokens, or change org settings."
}

variable "permissions" {
  description = "List of Okta admin permission types granted to this role"
  type        = list(string)
  default = [
    "okta.users.manage",
    "okta.users.read",
    "okta.groups.manage",
    "okta.groups.read",
  ]
}
