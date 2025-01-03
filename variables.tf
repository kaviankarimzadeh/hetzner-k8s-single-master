variable "hcloud_token" {}

variable "ip_range" {
  default = "10.0.1.0/24"
}

variable "os_type" {
  default = "ubuntu-24.04"
}

variable "master_server_type" {
  default = "cx22"
}

variable "worker_server_type" {
  default = "cx32"
}

variable "location" {
  default = "nbg1"
}

variable "worker_instances" {
  default = "6"
}

variable "services_protocol" {
  default = "tcp"
}

variable "services_workers_port_1" {
  default = "80"
}

variable "services_workers_port_2" {
  default = "443"
}

variable "lb_workers_private_ip" {
  default = "10.0.1.21"
}

variable "pod_subnet" {
  default = "10.244.0.0/20"
}

variable "kubernetes_version" {
  default = "1.31.1"
}

variable "kubernetes_package_version" {
  default = "1.31.2-1.1"
}

variable "k8s_repo_version" {
  default = "1.31"
}

variable "helm_version" {
  default = "3.16.4"
}

variable "containerd_version" {
  default = "1.7.19+really1.7.12-0ubuntu4.2"
}

variable "keepalived_version" {
  default = "1:2.2.8-1build2"
}

variable "cilium_version" {
  default = "1.16.5"
}

variable "ingress_nginx_version" {
  default = "4.12.0"
}

variable "eth_name" {
  default = "eth0"
}
