variable "do_token" {
  description = "DigitalOcean API token with read/write permissions; can also be set as env variable TF_VAR_do_token"
}

variable "cluster_name" {
  description = "Cluster base name"
}

variable "provision_ssh_pub" {
  description = "SSH public key"
  default     = "~/.ssh/digitalocean_rsa.pub"
}

variable "provision_ssh_priv_key" {
  default     = "~/.ssh/digitalocean_rsa"
  description = "File path to SSH private key used to access the provisioned nodes."
}

variable "provision_user" {
  default     = "core"
  description = "Host OS and SSH user used to log in to the droplets for issueing Docker commands"
}

variable "provision_ssh_port" {
  description = "SSH port; select a port != 22, not for security but to cut down on script kiddies banging on the default port"
  default     = "22"
}

variable "provision_docker_tls_certs" {
  description = "Path to docker TLS certs: ca.pem, server.pem, server-key.pem"
  default     = "~/.docker/do-cluster"
}

variable "region" {
  description = "Datacenter region in which the cluster will be created; see:  doctl compute region list"
  default     = "sfo2"
}

variable "image" {
  description = "OS image name, using DO's slug naming scheme; see: doctl compute image list-distribution --public"
  default     = "coreos-stable"
}

variable "size" {
  description = "Droplet size; see: doctl compute size list"
  default     = "s-1vcpu-1gb"
}

variable "manager_node_count" {
  description = "Number of manager nodes in the docker swarm; should be either 1, 3 or 5"
  default     = "3"
}

variable "worker_node_count" {
  description = "Number of worker nodes in the docker swarm; can be 0 or more nodes"
  default     = "1"
}
