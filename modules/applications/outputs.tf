# modules/applications/outputs.tf
#
# Exports the application ID and client ID.
# The client_id is what the actual app code needs to configure OIDC authentication.

output "app_id" {
  description = "Okta application ID"
  value       = okta_app_oauth.internal_dashboard.id
}

output "client_id" {
  description = "OIDC client ID — used by the application to authenticate users"
  value       = okta_app_oauth.internal_dashboard.client_id
}

output "app_label" {
  description = "Application display name"
  value       = okta_app_oauth.internal_dashboard.label
}
