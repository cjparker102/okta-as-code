# modules/groups/main.tf
#
# Creates department groups, role groups, and auto-assignment rules.
#
# This is the foundation of the IAM structure. Every other module
# depends on the group IDs created here.
#
# Key concept: JML (Joiner/Mover/Leaver) automation
#   - Joiner: new employee gets department attribute → group rule adds
#             them to the correct group automatically
#   - Mover:  department changes → old rule removes them, new rule adds them
#   - Leaver: account deactivated → rules stop applying, access revoked
#
# This eliminates manual group assignment and the human error that comes
# with it. No more tickets, no more waiting, no more forgotten access.


# ---------------------------------------------------------------------------
# Department Groups
# ---------------------------------------------------------------------------
# One group per department. Using for_each (not count) so that adding or
# removing a department doesn't destroy unrelated groups.
#
# With count, removing item [2] from a list shifts items [3], [4], [5]...
# and Terraform would destroy and recreate all of them. With for_each,
# each group is keyed by name — removing "HR" only affects HR.

resource "okta_group" "department" {
  for_each = toset(var.department_groups)

  name        = "Department - ${each.value}"
  description = "All ${each.value} team members — managed by Terraform"
}


# ---------------------------------------------------------------------------
# Role Groups
# ---------------------------------------------------------------------------
# Cross-department groups for organizational roles like Managers,
# Executives, and Contractors. These are used for policy targeting
# (e.g., stricter MFA for Executives) and access control.

resource "okta_group" "role" {
  for_each = toset(var.role_groups)

  name        = "Role - ${each.value}"
  description = "${each.value} role group — managed by Terraform"
}


# ---------------------------------------------------------------------------
# Group Rules (Auto-Assignment)
# ---------------------------------------------------------------------------
# These rules automatically assign users to department groups based on
# their profile.department attribute. This is the "Joiner" automation.
#
# When you create a user with department = "Engineering", Okta evaluates
# these rules and adds them to "Department - Engineering" automatically.
#
# The expression uses Okta Expression Language (OEL):
#   user.department == "Engineering"
#
# Why this matters: the chaos-generator creates "wrong_department_groups"
# as a chaos type — users in groups that don't match their department.
# With group rules, that can't happen. The rule enforces consistency.

resource "okta_group_rule" "department_auto_assign" {
  for_each = toset(var.department_groups)

  name              = "Auto-assign ${each.value}"
  status            = "ACTIVE"
  group_assignments = [okta_group.department[each.value].id]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "user.department==\"${each.value}\""
}
