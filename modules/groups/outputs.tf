# modules/groups/outputs.tf
#
# Exports group IDs so other modules can reference them.
#
# Without outputs, the applications module can't assign an app to the
# Engineering group — modules are intentionally isolated. They only
# share data through variables (inputs) and outputs (return values).

output "department_group_ids" {
  description = "Map of department name to Okta group ID"
  value       = { for k, v in okta_group.department : k => v.id }
}

output "role_group_ids" {
  description = "Map of role name to Okta group ID"
  value       = { for k, v in okta_group.role : k => v.id }
}

output "engineering_group_id" {
  description = "Engineering department group ID — used by the applications module"
  value       = okta_group.department["Engineering"].id
}

output "it_group_id" {
  description = "IT department group ID — used by policies and admin-roles modules"
  value       = okta_group.department["IT"].id
}

output "all_group_ids" {
  description = "Combined map of all group names to IDs"
  value = merge(
    { for k, v in okta_group.department : k => v.id },
    { for k, v in okta_group.role : k => v.id },
  )
}
