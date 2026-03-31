# modules/policies/main.tf
#
# Creates MFA enrollment and sign-on policies.
#
# Policies are the backbone of Zero Trust. Instead of hoping admins
# will enroll in MFA voluntarily, we ENFORCE it through policy.
#
# Two tiers:
#   1. Admin MFA (priority 1 — evaluated first, stricter)
#      → Requires password + FIDO2/WebAuthn for IT admin group
#   2. Standard MFA (priority 2 — fallback for everyone else)
#      → Requires password, Okta Verify optional
#
# The chaos-generator creates "admin_without_mfa" as a Critical finding.
# This Terraform config makes that scenario impossible — admins MUST
# have strong MFA enrolled before they can access anything.
#
# Note: This configuration targets Okta Identity Engine (OIE) orgs.
# Classic Engine orgs use different policy resource types.


# ---------------------------------------------------------------------------
# Data Source: Everyone Group
# ---------------------------------------------------------------------------
# Look up Okta's built-in "Everyone" group instead of hardcoding its ID.
# Data sources read existing state — they don't create anything.

data "okta_group" "everyone" {
  name = "Everyone"
}


# ---------------------------------------------------------------------------
# MFA Enrollment Policy: Admins (Strict)
# ---------------------------------------------------------------------------
# Priority 1 = evaluated first. If the user is in the IT admin group,
# this policy applies and the standard policy is skipped.
#
# FIDO2/WebAuthn is required — this is phishing-resistant MFA, the gold
# standard for admin accounts. A hardware key or biometric, not just
# a push notification that can be fatigue-attacked.

resource "okta_policy_mfa" "admin_mfa" {
  name        = "Admin MFA Enrollment"
  status      = "ACTIVE"
  description = "Requires strong MFA factors for admin users"
  priority    = 1

  groups_included = [var.it_admin_group_id]

  okta_password = {
    enroll = "REQUIRED"
  }

  fido_webauthn = {
    enroll = "REQUIRED"
  }
}

# Enrollment rule for the admin MFA policy
resource "okta_policy_rule_mfa" "admin_mfa_rule" {
  policy_id = okta_policy_mfa.admin_mfa.id
  name      = "Require MFA Enrollment for Admins"
  status    = "ACTIVE"
  enroll    = "LOGIN"
}


# ---------------------------------------------------------------------------
# MFA Enrollment Policy: Standard Users
# ---------------------------------------------------------------------------
# Priority 2 = fallback. Everyone not caught by the admin policy
# gets this softer policy — password required, Okta Verify optional.

resource "okta_policy_mfa" "standard_mfa" {
  name        = "Standard MFA Enrollment"
  status      = "ACTIVE"
  description = "Standard MFA enrollment for all users"
  priority    = 2

  groups_included = [data.okta_group.everyone.id]

  okta_password = {
    enroll = "REQUIRED"
  }

  okta_otp = {
    enroll = "OPTIONAL"
  }
}

# Enrollment rule for the standard MFA policy
resource "okta_policy_rule_mfa" "standard_mfa_rule" {
  policy_id = okta_policy_mfa.standard_mfa.id
  name      = "Standard MFA Enrollment"
  status    = "ACTIVE"
  enroll    = "LOGIN"
}


# ---------------------------------------------------------------------------
# Sign-On Policy: Admin Console Access
# ---------------------------------------------------------------------------
# Requires MFA every session for admin users accessing the Okta console.
# Even if they already enrolled, they must present their factor each login.
#
# This prevents session hijacking — if an attacker steals an admin's
# session cookie, they still can't access the admin console without
# the physical MFA device.

resource "okta_policy_signon" "admin_signon" {
  name        = "Admin Sign-On Policy"
  status      = "ACTIVE"
  description = "Requires MFA for every admin sign-on"
  priority    = 1

  groups_included = [var.it_admin_group_id]
}

resource "okta_policy_rule_signon" "admin_require_mfa" {
  policy_id          = okta_policy_signon.admin_signon.id
  name               = "Require MFA for Admins"
  status             = "ACTIVE"
  access             = "ALLOW"
  mfa_required       = true
  mfa_prompt         = "SESSION"
  session_idle        = 480
  session_lifetime    = 720
  session_persistent  = false
}
