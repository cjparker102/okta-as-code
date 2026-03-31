# modules/admin-roles/outputs.tf
#
# Exports the custom role and resource set IDs for auditing.

output "custom_role_id" {
  description = "Custom admin role ID"
  value       = okta_admin_role_custom.it_helpdesk.id
}

output "resource_set_id" {
  description = "Resource set ID scoping the custom role"
  value       = okta_resource_set.helpdesk_scope.id
}
