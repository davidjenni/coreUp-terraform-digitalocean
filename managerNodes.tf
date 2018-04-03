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
  user_data          = "${data.template_file.cloud_config.rendered}"

  connection {
    type        = "ssh"
    user        = "${var.provision_user}"
    private_key = "${file("${var.provision_ssh_priv_key}")}"
    port        = "${var.provision_ssh_port}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/init-swarm.sh ${digitalocean_droplet.manager.0.ipv4_address_private}"

    environment {
      DOCKER_TLS_VERIFY = 1
      DOCKER_HOST       = "tcp://${digitalocean_droplet.manager.0.ipv4_address}:2376"
      DOCKER_CERT_PATH  = "${pathexpand(var.provision_docker_tls_certs)}"
    }
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
  user_data          = "${data.template_file.cloud_config.rendered}"

  connection {
    type        = "ssh"
    user        = "${var.provision_user}"
    private_key = "${file("${var.provision_ssh_priv_key}")}"
    port        = "${var.provision_ssh_port}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/join-swarm.sh ${lookup(data.external.swarm_join_token.result, "manager")} ${digitalocean_droplet.manager.0.ipv4_address_private}"

    environment {
      DOCKER_TLS_VERIFY = 1
      DOCKER_HOST       = "tcp://${digitalocean_droplet.manager.0.ipv4_address}:2376"
      DOCKER_CERT_PATH  = "${pathexpand(var.provision_docker_tls_certs)}"
    }
  }
}

data "external" "swarm_join_token" {
  program = ["${path.module}/scripts/get-join-tokens.sh"]

  query = {
    host        = "${digitalocean_droplet.manager.0.ipv4_address}"
    user        = "${var.provision_user}"
    private_key = "${var.provision_ssh_priv_key}"
    port        = "${var.provision_ssh_port}"
  }
}

data "external" "compile_cloud_config" {
  program = ["${path.module}/scripts/compile-config.sh"]

  query = {
    config_yaml = "${path.module}/cloud-config.yaml"
    tls_dir     = "${pathexpand(var.provision_docker_tls_certs)}"
  }
}

data "template_file" "cloud_config" {
  template = "${lookup(data.external.compile_cloud_config.result, "config")}"

  vars {
    ssh_port = "${var.provision_ssh_port}"
  }
}
