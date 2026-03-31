# modules/admin-roles/main.tf
#
# Creates a custom admin role with least-privilege permissions.
#
# The problem: most orgs give IT staff SUPER_ADMIN because it's easy.
# SUPER_ADMIN can do EVERYTHING — create API tokens, modify security
# policies, delete the entire org. The chaos-generator creates
# "sleeping_super_admin" and "orphaned_admin" to simulate this risk.
#
# The solution: custom roles with exactly the permissions needed.
# An IT help desk person needs to:
#   - Read and manage users (password resets, profile updates)
#   - Read and manage groups (add/remove members)
# They do NOT need to:
#   - Modify authentication policies
#   - Create API tokens
#   - Change org-level settings
#   - Manage other admin roles
#
# By defining this in Terraform, the role definition is version-controlled.
# If someone tries to expand the permissions manually, `terraform plan`
# will flag the drift.


# ---------------------------------------------------------------------------
# Custom Admin Role
# ---------------------------------------------------------------------------
# Defines the role with a specific set of permissions.
# Each permission is an Okta API scope — granular control over what
# API operations this role can perform.

resource "okta_admin_role_custom" "it_helpdesk" {
  label       = var.role_label
  description = var.role_description
  permissions = var.permissions
}


# ---------------------------------------------------------------------------
# Resource Set
# ---------------------------------------------------------------------------
# Scopes the custom role to specific resources. This role can manage
# all users and all groups in the org, but nothing else.
#
# Resource sets use Okta's resource URN format. The URLs point to
# API endpoints that define the scope boundary.

resource "okta_resource_set" "helpdesk_scope" {
  label       = "Help Desk Resource Scope"
  description = "All users and groups — scoped for IT help desk operations"

  resources = [
    "https://${var.okta_org_name}.${var.okta_base_url}/api/v1/users",
    "https://${var.okta_org_name}.${var.okta_base_url}/api/v1/groups",
  ]
}


# ---------------------------------------------------------------------------
# Role Assignment
# ---------------------------------------------------------------------------
# Assigns the custom role to the IT group with the resource set scope.
# Every member of the IT group gets this role automatically.
#
# This is the same group-based pattern as the applications module —
# roles are assigned to groups, not individuals. When someone joins IT,
# they get the admin role. When they leave, they lose it.

resource "okta_admin_role_custom_assignments" "it_helpdesk_assignment" {
  resource_set_id = okta_resource_set.helpdesk_scope.id
  custom_role_id  = okta_admin_role_custom.it_helpdesk.id

  members = [var.it_admin_group_id]
}
