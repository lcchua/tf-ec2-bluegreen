# Hints
## Terraform Keywords
- provider
- backend
- variable
- resource
- data
- output

## Questions
- How many public and private subnets are there?
  - Are these VPC resources being created or referenced?
- Application load balancer
  - Where is it deployed?
  - What securitygroup is attached to it?
    - What traffic is allowed in/out?
  - How is the loadbalancer made aware on the readiness of its targets?
- EC2 (i.e. Blue Deployments)
  - Where is it deployed?
  - What securitygroup is attached to it?
    - What traffic is allowed in and out?
  - What is being hosted on these VMs?