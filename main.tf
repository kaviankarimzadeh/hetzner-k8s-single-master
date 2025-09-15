## Creating Private Network

resource "hcloud_network" "hc_private" {
  name     = "hc_private"
  ip_range = var.ip_range
}

resource "hcloud_network_subnet" "hc_private_subnet" {
  network_id   = hcloud_network.hc_private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.ip_range
}

## Provide SSH Key to manage servers

resource "hcloud_ssh_key" "mykey" {
  name       = "hetzner_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

## Creating servers

resource "hcloud_server" "kube_master" {
  name        = "kube-master1"
  image       = var.os_type
  server_type = var.master_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.mykey.id]
  user_data   = file("user_data.yml")
  labels = {
    type          = "master"
    ansible-group = "master_servers"
  }
  network {
    network_id = hcloud_network.hc_private.id
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  depends_on = [
    hcloud_network_subnet.hc_private_subnet
  ]
}

resource "hcloud_server" "kube_worker" {
  name        = "kube-worker${count.index + 1}"
  image       = var.os_type
  server_type = var.worker_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.mykey.id]
  count       = var.worker_instances
  user_data   = file("user_data.yml")
  labels = {
    type          = "worker"
    ansible-group = "worker_servers"
  }
  network {
    network_id = hcloud_network.hc_private.id
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  depends_on = [
    hcloud_network_subnet.hc_private_subnet
  ]
}

## Creating LB for Worker nodes

resource "hcloud_load_balancer" "workers_lb" {
  name               = "workers_lb"
  load_balancer_type = "lb11"
  location           = var.location
  labels = {
    type = "workers_lb"
  }
  algorithm {
    type = "round_robin"
  }
  depends_on = [ hcloud_server.kube_worker ]
}

resource "hcloud_load_balancer_target" "load_balancer_worker_target" {
  count            = var.worker_instances
  type             = "server"
  load_balancer_id = hcloud_load_balancer.workers_lb.id
  server_id        = hcloud_server.kube_worker[count.index].id
  depends_on = [ hcloud_load_balancer.workers_lb, hcloud_server.kube_worker ]
}

resource "hcloud_load_balancer_service" "workers_service_1" {
  load_balancer_id = hcloud_load_balancer.workers_lb.id
  protocol         = var.services_protocol
  listen_port      = var.services_workers_port_1
  destination_port = var.services_workers_port_1

  health_check {
    protocol = var.services_protocol
    port     = var.services_workers_port_1
    interval = "10"
    timeout  = "10"
    retries = 3
    http {
      path         = "/"
      status_codes = ["2??", "3??"]
    }
  }
  depends_on = [ hcloud_load_balancer.workers_lb ]
}

resource "hcloud_load_balancer_service" "workers_service_2" {
  load_balancer_id = hcloud_load_balancer.workers_lb.id
  protocol         = var.services_protocol
  listen_port      = var.services_workers_port_2
  destination_port = var.services_workers_port_2

  health_check {
    protocol = var.services_protocol
    port     = var.services_workers_port_2
    interval = "10"
    timeout  = "10"
    retries = 3
    http {
      path         = "/"
      status_codes = ["2??", "3??"]
    }
  }
  depends_on = [ hcloud_load_balancer.workers_lb ]
}

resource "hcloud_load_balancer_network" "workers_network" {
  load_balancer_id        = hcloud_load_balancer.workers_lb.id
  subnet_id               = hcloud_network_subnet.hc_private_subnet.id
  enable_public_interface = "true"
  ip                      = var.lb_workers_private_ip
  depends_on = [
    hcloud_network_subnet.hc_private_subnet
  ]
}

## To add an extra Volume to Worker node for rook ceph
resource "hcloud_volume" "worker_volume" {
  count = var.worker_instances

  name     = "worker-volume-${count.index + 1}"
  size     = 10
  location = var.location
  format   = "ext4"
  labels = {
    type = "worker_volume"
  }
  depends_on = [hcloud_server.kube_worker]
}

## Attach the volumes to the worker servers
resource "hcloud_volume_attachment" "worker_volume_attachment" {
  count = var.worker_instances

  server_id = hcloud_server.kube_worker[count.index].id
  volume_id = hcloud_volume.worker_volume[count.index].id
}
