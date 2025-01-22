# tf-ec2-bluegreen

## Task 1: CI Workflow
- Do the neccessary to have `terraform-checks` workflow runs successfully
- Hints:
    - Terraform initialization is needed before validation
    - Use the `-backend=false` during the tf init step as state is irrelavent to the integration process

## Task 2: CD Workflow
- Ensure remote backend is configured properly prior to this
- Do the neccessary to have `deployment` workflow runs successfully

## Task 3: Implement Green Deployment
- Uncomment all green deployment codeblocks
- Terraform apply using the different traffic distribution options
    - Use `-var` flag
- Run the test command to see the traffic distribution in effect

## Task 4: CD Workflow with Blue-Green options
- Create a new workflow that has blue-green deployment options

# Test
Use the the command to make a call to the service repeatedly
```bash
for i in `seq 1 10`; do curl $(terraform output -raw lb_dns_name); done
```

# References
- https://learn.hashicorp.com/tutorials/terraform/blue-green-canary-tests-deployments
