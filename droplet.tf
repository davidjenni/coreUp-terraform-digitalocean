provider "digitalocean" {
  token   = "${var.do_token}"
  version = "~> 0.1"
}

resource "digitalocean_tag" "cluster" {
  name = "docker_swarm"
}

resource "digitalocean_tag" "manager" {
  name = "manager"
}

resource "digitalocean_tag" "worker" {
  name = "worker"
}

resource "digitalocean_ssh_key" "core" {
  name       = "Terraform SSH key for cluster ${var.cluster_name}"
  public_key = "${file("${var.provision_ssh_pub}")}"
}

resource "digitalocean_droplet" "manager" {
  region             = "${var.region}"
  image              = "${var.image}"
  size               = "${var.size}"
  private_networking = true
  ipv6               = true
  count              = 1
  name               = "${format("%s-manager-%02d.%s", var.cluster_name, count.index + 1, var.region)}"
  ssh_keys           = ["${digitalocean_ssh_key.core.fingerprint}"]
  tags               = ["${digitalocean_tag.cluster.name}", "${digitalocean_tag.manager.name}"]

  connection {
    type        = "ssh"
    user        = "${var.provision_user}"
    private_key = "${file("${var.provision_ssh_priv_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! $(sudo docker info) ]; do sleep 2; done",
      "if [ ${count.index} -eq 0 ]; then sudo docker swarm init --advertise-addr ${digitalocean_droplet.manager.0.ipv4_address_private}; exit 0; fi",
    ]
  }
}
