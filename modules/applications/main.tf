# modules/applications/main.tf
#
# Creates an OIDC application with group-based assignment.
#
# Key IAM best practice: apps are assigned to GROUPS, not individual users.
#
# Why this matters:
#   - When a new engineer joins and lands in the Engineering group (via the
#     group rule), they automatically get this app. No tickets needed.
#   - When someone leaves Engineering, the group rule removes them, and
#     they lose app access immediately.
#   - The chaos-generator creates "app_hoarder" — users with 15-25 apps
#     accumulated over time. That happens when apps are assigned to
#     individuals manually. Group-based assignment prevents it entirely.


# ---------------------------------------------------------------------------
# OIDC Application
# ---------------------------------------------------------------------------
# This creates a server-side web app using the Authorization Code flow —
# the most common and secure pattern for internal tools.
#
# redirect_uris uses localhost for dev. In production, you'd set this to
# your real app URL (e.g., https://dashboard.acmecorp.com/callback).

resource "okta_app_oauth" "internal_dashboard" {
  label       = var.app_label
  type        = "web"
  grant_types = ["authorization_code"]
  redirect_uris = [
    "https://localhost:8080/callback",
  ]
  response_types = ["code"]

  # Let Terraform manage group assignments via the separate resource below,
  # not inline. This prevents conflicts between the two approaches.
  lifecycle {
    ignore_changes = [groups]
  }
}


# ---------------------------------------------------------------------------
# Group-Based App Assignment
# ---------------------------------------------------------------------------
# Instead of assigning the app to john.doe, sarah.smith, etc. one by one,
# we assign it to the Engineering group. Everyone in that group gets access.
#
# This is the difference between imperative access management (chaos-generator
# style: loop through users, assign apps) and declarative (Terraform style:
# state that Engineering should have this app, let Okta handle the rest).

resource "okta_app_group_assignment" "engineering_access" {
  app_id   = okta_app_oauth.internal_dashboard.id
  group_id = var.engineering_group_id
}
