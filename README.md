# coreUp-terraform-digitalocean

Bring up a coreOS cluster with docker swarm using [Terraform](https://terraform.io).
This repo represents a Terraform module which can be instantiated as:

```terraform
module "testCluster" {
  source = "github.com/davidjenni/coreUp-terraform-digitalocean?ref=v0.1.0"

  do_token = "${var.do_token}"

  cluster_name       = "mycluster"
  region             = "sfo2"
  manager_node_count = 3
  worker_node_count  = 1
}
```

See the example/ folder for a starting point of a module definition.

## Dev environment

```fish
brew install terraform
```

## Testing

This repo's root folder represents a [terraform module](https://www.terraform.io/docs/modules/usage.html),
so to test, plan and apply from the example subfolder to be able to use it as a module definition.

```fish
cd example
set -x TF_VAR_do_token <<token>>
terraform init
terraform get
terraform plan
terraform apply
```
