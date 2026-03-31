# outputs.tf
#
# Root-level outputs — values displayed after `terraform apply`.
#
# Outputs are how Terraform tells you what it created. They print to
# the terminal after every apply, and other Terraform projects can
# reference them if you use remote state.
#
# Think of these like the summary that cleanup.py prints after deleting
# resources — "30 groups created, 80 users created."

output "department_group_ids" {
  description = "Map of department name to Okta group ID"
  value       = module.groups.department_group_ids
}

output "role_group_ids" {
  description = "Map of role name to Okta group ID"
  value       = module.groups.role_group_ids
}

output "app_client_id" {
  description = "OIDC client ID for the Internal Dashboard application"
  value       = module.applications.client_id
}

output "mfa_policy_id" {
  description = "MFA enrollment policy ID for admin users"
  value       = module.policies.admin_mfa_policy_id
}

output "custom_admin_role_id" {
  description = "Custom least-privilege admin role ID"
  value       = module.admin_roles.custom_role_id
}
