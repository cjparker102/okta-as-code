# versions.tf
#
# Pins the Terraform version and the Okta provider version.
#
# The ~> operator is a "pessimistic constraint" — it allows patch updates
# (6.6.1 → 6.6.2) but blocks minor/major bumps (6.7.0 or 7.0.0).
# This prevents breaking changes from sneaking in when you run `terraform init`.
#
# In a production environment, you would also configure a remote backend here
# (e.g., S3 + DynamoDB or Terraform Cloud) so the state file is shared across
# the team and protected by locking. For this portfolio project, local state
# is sufficient.

terraform {
  required_version = ">= 1.5"

  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 6.6"
    }
  }
}
