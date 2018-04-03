resource "digitalocean_droplet" "worker" {
  region             = "${var.region}"
  image              = "${var.image}"
  size               = "${var.size}"
  private_networking = true
  ipv6               = true
  count              = "${var.worker_node_count}"
  name               = "${format("%s-worker-%02d.%s", var.cluster_name, count.index + 1, var.region)}"
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
    command = "${path.module}/scripts/join-swarm.sh ${lookup(data.external.swarm_join_token.result, "worker")} ${digitalocean_droplet.manager.0.ipv4_address_private}"

    environment {
      DOCKER_TLS_VERIFY = 1
      DOCKER_HOST       = "tcp://${digitalocean_droplet.manager.0.ipv4_address}:2376"
      DOCKER_CERT_PATH  = "${pathexpand(var.provision_docker_tls_certs)}"
    }
  }
}
