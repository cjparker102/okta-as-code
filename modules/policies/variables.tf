# modules/policies/variables.tf
#
# Input variables for the policies module.
#
# Policies are targeted at specific groups — the IT admin group gets
# stricter MFA requirements than standard users.

variable "it_admin_group_id" {
  description = "Okta group ID for IT admins — targeted by the strict MFA policy"
  type        = string
}
