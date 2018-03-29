terraform {
  required_version = "~>0.11"
}

module "testCluster" {
  # in an actual use-case scenario, this module definition is in its own repo
  # this allows to reference this module via a versioned github reference:
  #
  # source = "github.com/davidjenni/coreUp-terraform-digitalocean?ref=v0.1.0"
  source = ".."

  do_token = "${var.do_token}"

  cluster_name       = "test"
  region             = "sfo1"
  manager_node_count = 1
  worker_node_count  = 1
  provision_ssh_port = 4410
}

output "manager" {
  value       = "${element(module.testCluster.ipv4_addresses, 1)}"
  description = "The manager nodes' public ipv4 adresses"
}

output "sshKeyFile" {
  value = "${module.testCluster.sshKeyFile}"
}

output "sshPort" {
  value = "${module.testCluster.sshPort}"
}

output "sshUser" {
  value = "${module.testCluster.sshUser}"
}
