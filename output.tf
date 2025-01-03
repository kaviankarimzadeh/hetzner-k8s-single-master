output "kube_masters_status" {
  value = {
    "name"   = hcloud_server.kube_master.name
    "status" = hcloud_server.kube_master.status
  }
}

output "kube_masters_ips" {
  value = {
    "name" = hcloud_server.kube_master.name
    "ipv4" = hcloud_server.kube_master.ipv4_address
  }
}

output "kube_workers_status" {
  value = {
    for server in hcloud_server.kube_worker :
    server.name => server.status
  }
}

output "kube_workers_ips" {
  value = {
    for server in hcloud_server.kube_worker :
    server.name => server.ipv4_address
  }
}

output "lb_workers_ip" {
  description = "Load balancer Workers IP address"
  value       = hcloud_load_balancer.workers_lb.ipv4
}
