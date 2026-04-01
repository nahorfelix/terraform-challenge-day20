# Day 20 - Workflow for Deploying Application Code (Submission)

**Public repo:** https://github.com/nahorfelix/terraform-challenge-day20

## Seven-Step Walkthrough

**1) Version control**  
Used GitHub with feature branch + PR workflow.
- Branch: `update-app-version-day20`
- PR: https://github.com/nahorfelix/terraform-challenge-day20/pull/1
- Recent log: `d62a59e`, `9ff6fc9 (tag: v1.3.0)`, `7373aab`

**2) Run locally**  
Ran and reviewed plan before apply:
```bash
terraform plan -out=day20.tfplan
```

**3) Make code change**  
Updated `webserver-cluster-dev/user-data.sh` from `Day 20 webserver v2` to `Day 20 webserver v3`.
```bash
git checkout -b update-app-version-day20
git add .
git commit -m "Update app response to v3 for Day 20"
git push origin update-app-version-day20
```

**4) Submit for review**  
Opened PR and included plan context so reviewer could evaluate resource impact.  
Screenshot description: PR page showing changed `user-data.sh` + plan snippet.

**5) Run automated tests**  
Workflow `.github/workflows/terraform-test.yml` ran on PR with:
- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`

**6) Merge and release**  
Merged PR to `main` and tagged:
```bash
git tag -a "v1.3.0" -m "Update app response to v3"
git push origin v1.3.0
```

**7) Deploy**  
Ran plan/apply from merge commit. Apply partially succeeded, then ASG launch failed due account free-tier/instance eligibility policy. I captured logs and immediately ran `terraform destroy -auto-approve`.

## Terraform Plan Output (Step 2)

From `docs/plan-feature-v3.txt`:
```text
Terraform used the selected providers to generate the following execution plan.
  + create
# aws_launch_template.web will be created
+ user_data = "...Day 20 webserver v3..."
Plan: 8 to add, 0 to change, 0 to destroy.
Saved the plan to: day20.tfplan
```
This matched intent: deploy path reflects new app response version (`v3`).

## Terraform Cloud Setup

Terraform Cloud block prepared:
```hcl
terraform {
  cloud {
    organization = "your-org-name"
    workspaces { name = "webserver-cluster-dev" }
  }
}
```
Migration flow: `terraform login` then `terraform init` (state migration prompt).

UI confirmation criteria after migration:
- workspace `webserver-cluster-dev`
- state versions history
- run history (plan/apply)
- variable settings and audit trail

## Variable Configuration (Terraform Cloud)

Configured/planned:
- **Sensitive env vars:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- **Terraform vars:** `cluster_name`, `instance_type`, `min_size`, `max_size`, `environment`, `server_port`

Sensitive values must never be in `.tf` files or CI logs because secrets leak via git history, logs, artifacts, and screenshots.

## Private Registry

Setup used/documented:
1. Create repo `terraform-aws-webserver-cluster`
2. Tag release `v1.0.0`
3. Publish in Terraform Cloud Registry

Team source URL:
```hcl
source  = "app.terraform.io/your-org/webserver-cluster/aws"
version = "1.0.0"
```
Advantages vs GitHub URL: version pinning, discoverability, standardized docs, org governance/access control.

## Workflow Comparison Table

| Step | Application Code | Infrastructure Code | Key Difference |
|---|---|---|---|
| 1 | Git source | Git `.tf` files | State not in Git |
| 2 | Run app locally | `terraform plan` | Predictive diff, not running app |
| 3 | Edit app code | Edit IaC | Changes affect cloud resources |
| 4 | PR diff review | PR + plan review | Must assess blast radius/cost/security |
| 5 | Unit/lint tests | `fmt`/`validate`/`terraform test`/Terratest | Infra tests can cost money |
| 6 | Merge + release | Merge + tag | Consumers pin module versions |
| 7 | Deploy pipeline | `terraform apply` | Must run from trusted, locked env |

Biggest difference: **Step 7**, because infra apply has direct operational and cost impact.

## Chapter 10 Learnings

Most important insight: Terraform should follow the same release discipline as application code, but with stricter controls around plan review, credentials, and deployment environment. If teams skip PR review, tests, or controlled apply, they lose auditability and increase outage/cost risk.

## Challenges and Fixes

- **Deploy failure:** ASG instance launch blocked by account free-tier eligibility policy.  
  **Fix:** captured evidence and immediately destroyed created resources.
- **Terraform Cloud practical blocker:** org/workspace access required to complete migration in this environment.  
  **Fix:** prepared valid cloud block, migration commands, and variable model for direct execution.
- **Secrets risk:** accidental exposure in files/logs.  
  **Fix:** use Terraform Cloud sensitive env vars for credentials.
