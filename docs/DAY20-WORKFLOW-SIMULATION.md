# Day 20 - Workflow for Deploying Application Code (simulation record)

## Context
- Repo: https://github.com/nahorfelix/terraform-challenge-day20
- PR: https://github.com/nahorfelix/terraform-challenge-day20/pull/1
- Release tag: `v1.3.0`
- Root used: `webserver-cluster-dev/`

## Step 1 - Use version control
- Terraform code is in GitHub.
- Main branch is used as release branch; change was made via feature branch + PR.
- Feature branch created: `update-app-version-day20`.

## Step 2 - Run locally
- Updated app response target from v2 to v3 in `user-data.sh`.
- Ran:
  - `terraform plan -out=day20.tfplan`
- Saved plan output:
  - `docs/plan-feature-v3.txt`

## Step 3 - Make code change
- Changed:
  - `echo "<h1>Day 20 webserver v2</h1>"`
  - to `echo "<h1>Day 20 webserver v3</h1>"`
- Committed and pushed branch with message:
  - `Update app response to v3 for Day 20`

## Step 4 - Submit for review
- Opened PR and included Terraform plan summary in PR body.
- Reviewer context: plan output showed expected launch template user_data update path.

## Step 5 - Run automated tests
- GitHub Actions workflow (`.github/workflows/terraform-test.yml`) runs on PR/push.
- Checks include:
  - `terraform fmt -check -recursive`
  - `terraform init -backend=false`
  - `terraform validate`

## Step 6 - Merge and release
- Merged PR #1 to `main`.
- Tagged release:
  - `git tag -a "v1.3.0" -m "Update app response to v3"`
  - `git push origin v1.3.0`

## Step 7 - Deploy
- Ran from merge state:
  - `terraform plan -out=day20.tfplan`
  - `terraform apply day20.tfplan`
- Result:
  - Partial deploy succeeded (ALB + SG + LT), but ASG failed to launch due account free-tier/instance eligibility policy.
- Verification:
  - ALB URL captured in `docs/deploy-verification.txt`
- Safety cleanup executed immediately:
  - `terraform destroy -auto-approve`
  - log: `docs/destroy-after-failed-apply.txt`

## Terraform Cloud setup (documented for team workflow)
Use this block in the Terraform root:

```hcl
terraform {
  cloud {
    organization = "your-org-name"

    workspaces {
      name = "webserver-cluster-dev"
    }
  }
}
```

Then run:
- `terraform login`
- `terraform init` (state migration prompt)

Workspace variable guidance:
- Sensitive env vars: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- Terraform vars: `cluster_name`, `instance_type`, `min_size`, `max_size`, `environment`

## Terraform Cloud private registry notes
- Create module repo with naming convention:
  - `terraform-aws-webserver-cluster`
- Tag release:
  - `git tag v1.0.0 && git push origin v1.0.0`
- Publish in Terraform Cloud: Registry -> Publish -> Module

Consumption pattern:

```hcl
module "webserver_cluster" {
  source  = "app.terraform.io/your-org/webserver-cluster/aws"
  version = "1.0.0"

  cluster_name  = "prod-cluster"
  instance_type = "t2.medium"
  min_size      = 3
  max_size      = 10
  environment   = "production"
}
```

## Workflow comparison map

| Step | Application Code | Infrastructure Code | Key Difference |
|---|---|---|---|
| 1 | Git source | Git `.tf` files | State not stored in Git |
| 2 | Run app locally | `terraform plan` | Plan predicts change; no running app |
| 3 | Edit app files | Edit Terraform | Changes affect cloud resources |
| 4 | PR code diff | PR + plan output | Reviewer evaluates infra blast radius |
| 5 | Unit/lint tests | `fmt`, `validate`, `terraform test`, Terratest | Infra tests can create cloud cost |
| 6 | Merge + tag | Merge + tag | Module consumers pin versions |
| 7 | Deploy via CI/CD | `terraform apply` | Must run from trusted, locked workflow |
