# main.tf
#
# Root module — the entry point for the entire Terraform configuration.
#
# This file does two things:
#   1. Configures the Okta provider (how Terraform authenticates to your org)
#   2. Calls the four child modules and wires their inputs/outputs together
#
# Think of this like main.py in the chaos-generator — it orchestrates
# everything but delegates the real work to the modules.


# ---------------------------------------------------------------------------
# Provider Configuration
# ---------------------------------------------------------------------------
# The provider block tells Terraform how to connect to Okta.
# It's like build_client() in the chaos-generator — same concept,
# different syntax.

provider "okta" {
  org_name  = var.okta_org_name
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}


# ---------------------------------------------------------------------------
# Module: Groups
# ---------------------------------------------------------------------------
# Creates department groups, role groups, and auto-assignment rules.
# This module has no dependencies — it runs first.

module "groups" {
  source = "./modules/groups"
}


# ---------------------------------------------------------------------------
# Module: Applications
# ---------------------------------------------------------------------------
# Creates an OIDC app and assigns it to the Engineering group.
# Depends on the groups module for the group ID.

module "applications" {
  source = "./modules/applications"

  # Pass the Engineering group ID so the app can be assigned to it.
  # This is how modules share data — outputs from one become inputs to another.
  engineering_group_id = module.groups.engineering_group_id
}


# ---------------------------------------------------------------------------
# Module: Policies
# ---------------------------------------------------------------------------
# Creates MFA enrollment and sign-on policies.
# Targets the IT group for stricter admin MFA requirements.

module "policies" {
  source = "./modules/policies"

  it_admin_group_id = module.groups.it_group_id
}


# ---------------------------------------------------------------------------
# Module: Admin Roles
# ---------------------------------------------------------------------------
# Creates a custom least-privilege admin role and assigns it to IT.
# Instead of giving IT staff SUPER_ADMIN, they get exactly the
# permissions they need — and nothing more.

module "admin_roles" {
  source = "./modules/admin-roles"

  it_admin_group_id = module.groups.it_group_id
  okta_org_name     = var.okta_org_name
  okta_base_url     = var.okta_base_url
}
