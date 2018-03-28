terraform {
  required_version = "~>0.11"
}

provider "digitalocean" {
  token   = "${var.do_token}"
  version = "~> 0.1"
}

provider "external" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
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
  count              = "1"
  name               = "${format("%s-manager-%02d.%s", var.cluster_name, count.index + 1, var.region)}"
  ssh_keys           = ["${digitalocean_ssh_key.core.fingerprint}"]
  tags               = ["${digitalocean_tag.cluster.name}", "${digitalocean_tag.manager.name}"]

  connection {
    type        = "ssh"
    user        = "${var.provision_user}"
    private_key = "${file("${var.provision_ssh_priv_key}")}"
    port        = 22
  }

  provisioner "remote-exec" {
    # inline = "${file("${data.template_file.initSwarm.*.rendered}")}"

    inline = [
      "while [ ! $(docker info -f '{{json .OperatingSystem}}') ]; do sleep 2; done",
      "docker swarm init --advertise-addr ${digitalocean_droplet.manager.0.ipv4_address_private}; exit $?",
    ]
  }
}

resource "digitalocean_droplet" "co-manager" {
  region             = "${var.region}"
  image              = "${var.image}"
  size               = "${var.size}"
  private_networking = true
  ipv6               = true
  count              = "${var.manager_node_count - 1}"
  name               = "${format("%s-manager-%02d.%s", var.cluster_name, count.index + 2, var.region)}"
  ssh_keys           = ["${digitalocean_ssh_key.core.fingerprint}"]
  tags               = ["${digitalocean_tag.cluster.name}", "${digitalocean_tag.manager.name}"]

  connection {
    type        = "ssh"
    user        = "${var.provision_user}"
    private_key = "${file("${var.provision_ssh_priv_key}")}"
    port        = 22
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! $(docker info -f '{{json .OperatingSystem}}') ]; do sleep 2; done",
      "docker swarm join --token ${lookup(data.external.swarm_join_token.result, "manager")} ${element(digitalocean_droplet.manager.*.ipv4_address_private, 0)}:2377; exit $?",
    ]
  }
}

data "external" "swarm_join_token" {
  program = ["${path.module}/getSwarmJoinTokens.sh"]

  query = {
    host        = "${digitalocean_droplet.manager.0.ipv4_address}"
    user        = "${var.provision_user}"
    private_key = "${var.provision_ssh_priv_key}"
  }
}
