# okta-as-code

Terraform-managed Okta infrastructure — groups, applications, policies, and admin roles defined as code. The **prevention** layer of a complete IAM lifecycle.

## The IAM Lifecycle

This project is part of a three-repo IAM toolkit. Each repo handles a different phase:

```
┌─────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│  okta-as-code   │     │ okta-access-reviewer  │     │ okta-chaos-generator │
│                 │     │                       │     │                      │
│   PREVENT       │     │   DETECT              │     │   PRACTICE           │
│   Define the    │────▶│   Find drift and      │────▶│   Train on realistic │
│   correct state │     │   anomalies with AI   │     │   broken orgs        │
│   as code       │     │   analysis            │     │   (CTF-style)        │
└─────────────────┘     └──────────────────────┘     └──────────────────────┘
```

| Repo | Purpose | Tool |
|------|---------|------|
| [okta-as-code](https://github.com/cjparker102/okta-as-code) | Define correct IAM state, enforce through code | Terraform |
| [okta-access-reviewer](https://github.com/cjparker102/okta-access-reviewer) | Audit Okta org for security issues | Python + AI |
| [okta-chaos-generator](https://github.com/cjparker102/okta-chaos-generator) | Populate Okta with intentionally broken accounts | Python + Okta SDK |

## What is Terraform?

**Terraform** is an Infrastructure as Code (IaC) tool. Instead of clicking through the Okta admin console to create groups and configure policies, you write configuration files that describe what you want to exist. Terraform reads those files and makes it happen.

**Key concepts:**

- **Declarative** — You describe *what* you want, not *how* to get there. Write "I want an Engineering group" and Terraform handles the API calls.
- **State tracking** — Terraform remembers what it created (in a state file), so it can update or destroy resources cleanly. Similar to `.session.json` in the chaos-generator.
- **Plan before apply** — `terraform plan` shows exactly what will change before you commit to it. Like `dry_run.py` in the chaos-generator.
- **Drift detection** — If someone changes something manually in the Okta console, `terraform plan` flags the difference. Your `.tf` files are the source of truth.
- **Idempotent** — Running `terraform apply` twice produces the same result. If everything already matches the config, nothing changes.

## What This Repo Manages

Four modules, each handling a domain of IAM:

| Module | Resources Created | IAM Concept |
|--------|-------------------|-------------|
| `groups` | 7 department groups, 3 role groups, auto-assignment rules | **JML Automation** — users land in correct groups based on profile attributes |
| `applications` | 1 OIDC app with group-based assignment | **Least Privilege** — apps assigned to groups, not individuals |
| `policies` | MFA enrollment + sign-on policies | **Zero Trust** — MFA enforced for admins, not optional |
| `admin-roles` | Custom admin role with scoped permissions | **Least Privilege** — no more SUPER_ADMIN for help desk tasks |

### How the modules connect

```
                    ┌──────────┐
                    │  groups   │
                    └────┬─────┘
                         │ group IDs
              ┌──────────┼──────────┐
              v          v          v
       ┌────────────┐ ┌──────┐ ┌────────────┐
       │applications│ │policy│ │admin-roles  │
       └────────────┘ └──────┘ └────────────┘
```

Groups are created first. The other three modules receive group IDs as inputs so they can target the right groups for app assignments, policy enforcement, and role assignments.

## Setup

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- An Okta developer org ([sign up free](https://developer.okta.com/signup/))
- An Okta API token with Super Admin permissions

### Quick Start

```bash
# Clone the repo
git clone https://github.com/cjparker102/okta-as-code.git
cd okta-as-code

# Create your local variable file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Okta org name and API token

# Download the Okta provider
terraform init

# Preview what will be created (dry run)
terraform plan

# Create everything in your Okta org
terraform apply

# When you're done — tear it all down
terraform destroy
```

### Environment Variables (Alternative)

Instead of putting credentials in `terraform.tfvars`, you can use environment variables:

```bash
export TF_VAR_okta_org_name="your-dev-org"
export TF_VAR_okta_api_token="your-api-token"
terraform plan
```

## Source of Truth

Once resources are defined in Terraform, the `.tf` files become the **single source of truth** for your Okta configuration.

This means:
- Want to add a new department group? Add it to `modules/groups/variables.tf` and run `terraform apply`.
- Want to change the MFA policy? Edit `modules/policies/main.tf`, open a PR, get it reviewed, then apply.
- Someone manually changed a group in the Okta console? `terraform plan` shows the drift and `terraform apply` fixes it.

No more undocumented changes. No more "who created this group and why?" Every change is in git history with a commit message.

## Drift Detection

```bash
# See if anyone changed something manually in Okta
terraform plan

# If there's drift, fix it — restore Okta to match the code
terraform apply
```

When `terraform plan` shows "No changes," your Okta org matches the code exactly. When it shows changes you didn't make, someone went around the process — and you can revert it immediately.

## Project Structure

```
okta-as-code/
├── main.tf                           # Root module — provider + module calls
├── variables.tf                      # Root input variables (org name, token)
├── outputs.tf                        # Root outputs (resource IDs)
├── versions.tf                       # Terraform + provider version pins
├── terraform.tfvars.example          # Template for local variable values
├── modules/
│   ├── groups/
│   │   ├── main.tf                   # Department groups, role groups, rules
│   │   ├── variables.tf              # Group name lists
│   │   └── outputs.tf                # Group ID exports
│   ├── applications/
│   │   ├── main.tf                   # OIDC app + group assignment
│   │   ├── variables.tf              # App config + group ID input
│   │   └── outputs.tf                # Client ID export
│   ├── policies/
│   │   ├── main.tf                   # MFA + sign-on policies and rules
│   │   ├── variables.tf              # Group ID input for targeting
│   │   └── outputs.tf                # Policy ID exports
│   └── admin-roles/
│       ├── main.tf                   # Custom role + resource set + assignment
│       ├── variables.tf              # Permissions list + group ID input
│       └── outputs.tf                # Role ID exports
└── .github/
    └── workflows/
        └── terraform-plan.yml        # CI: format, validate, plan on PRs
```

## CI/CD Pipeline

Every Pull Request triggers a GitHub Actions workflow that:

1. **Format check** — ensures consistent HCL style (`terraform fmt`)
2. **Init** — downloads the Okta provider
3. **Validate** — catches syntax and reference errors
4. **Plan** — shows exactly what would change in Okta

The plan output is posted as a PR comment so reviewers can see the infrastructure impact before approving. No change hits production without review.

To enable the workflow, add your Okta API token as a GitHub secret:

**Settings → Secrets and variables → Actions → New repository secret**
- Name: `OKTA_API_TOKEN`
- Value: your Okta API token

## Commands Reference

| Command | What it does | Equivalent |
|---------|-------------|------------|
| `terraform init` | Downloads the Okta provider plugin | `pip install -r requirements.txt` |
| `terraform plan` | Shows what would change (dry run) | `python dry_run.py` |
| `terraform apply` | Creates/updates resources in Okta | `python main.py` |
| `terraform destroy` | Deletes everything Terraform created | `python cleanup.py` |
| `terraform fmt` | Formats `.tf` files consistently | `black .` (Python formatter) |
| `terraform validate` | Checks syntax without connecting to Okta | `python -m py_compile` |
