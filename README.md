# Day 20 - Workflow for Deploying Application Code

This repository simulates the 7-step application deployment workflow using Terraform infrastructure code.

## Layout
- `webserver-cluster-dev/` - Terraform root used for the workflow simulation
- `docs/DAY20-WORKFLOW-SIMULATION.md` - step-by-step execution record
- `.github/workflows/terraform-test.yml` - PR checks and push checks

## Day 20 goals completed
- Version-controlled Terraform change on a feature branch
- Local plan review before release (`terraform plan -out=day20.tfplan`)
- Pull request flow with plan context
- Automated checks on pull request
- Merge/tag/release workflow
- Terraform Cloud setup notes (workspace + variables)
- Private registry publication notes
