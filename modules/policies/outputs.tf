# modules/policies/outputs.tf
#
# Exports policy IDs for reference and auditing.

output "admin_mfa_policy_id" {
  description = "MFA enrollment policy ID for admin users"
  value       = okta_policy_mfa.admin_mfa.id
}

output "standard_mfa_policy_id" {
  description = "MFA enrollment policy ID for standard users"
  value       = okta_policy_mfa.standard_mfa.id
}

output "admin_signon_policy_id" {
  description = "Sign-on policy ID requiring MFA for admin access"
  value       = okta_policy_signon.admin_signon.id
}
