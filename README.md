# sctp-ce-cicd-demo

## Task 1
1. Read the terraform files and attempt to draw the architecture diagram
1. Deploy from laptop
1. Do the neccessary to have `terraform-checks` workflow runs successfully

## Task 2:
1. Uncomment all green deployment codeblocks
2. Use deployment to flip traffic between blue and green (e.g. `terraform apply -no-color -var 'traffic_distribution=blue' -var 'enable_blue_env=true' -var 'enable_green_env=true`)

# Test
Use the the command to make a call to the service repeatedly
```bash
for i in `seq 1 10`; do curl $(terraform output -raw lb_dns_name); done
```

## references
- https://learn.hashicorp.com/tutorials/terraform/blue-green-canary-tests-deployments
