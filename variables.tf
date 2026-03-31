# variables.tf
#
# Root-level input variables for the Okta organization.
#
# These work like function parameters — they let you configure the project
# without hardcoding values. Sensitive values (like the API token) are marked
# so Terraform never prints them in logs or plan output.
#
# Values are provided via:
#   1. terraform.tfvars file (gitignored — your local copy)
#   2. Environment variables (e.g., TF_VAR_okta_api_token)
#   3. Command line flags (-var="okta_org_name=dev-12345")

variable "okta_org_name" {
  description = "Your Okta org subdomain — the part before .okta.com (e.g., dev-12345678)"
  type        = string
}

variable "okta_base_url" {
  description = "Okta domain suffix — okta.com for production, oktapreview.com for sandbox"
  type        = string
  default     = "okta.com"
}

variable "okta_api_token" {
  description = "Okta API token — generate in Admin Console: Security > API > Tokens"
  type        = string
  sensitive   = true
}
