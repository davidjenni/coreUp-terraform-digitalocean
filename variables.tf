variable "do_token" {
  description = "DigitalOcean API token with read/write permissions"
}

variable "cluster_name" {
  description = "Cluster name"
  default     = "test"
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
  description = "User used to log in to the droplets via ssh for issueing Docker commands"
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
