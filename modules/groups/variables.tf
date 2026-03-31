# modules/groups/variables.tf
#
# Input variables for the groups module.
#
# By making these configurable with defaults, the module works out of the
# box but can be customized. Want to add a "Security" department later?
# Just add it to the list — no code changes needed.

variable "department_groups" {
  description = "List of department names — one Okta group is created per department"
  type        = list(string)
  default = [
    "Engineering",
    "Sales",
    "HR",
    "Finance",
    "IT",
    "Marketing",
    "Legal",
  ]
}

variable "role_groups" {
  description = "List of organizational role names — cross-department groups"
  type        = list(string)
  default = [
    "Managers",
    "Executives",
    "Contractors",
  ]
}
