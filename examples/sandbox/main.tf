provider "google-beta" {
  region = "${var.region}"
}

variable "region" {
  default = "europe-north1"
}

variable "project" {
  default = "petri-sandbox"
}

variable "endpoints" {
  type = "list"
  default = ["192.168.11.1", "192.168.11.2"]
}

data "template_file" "single_ip" {
  count    = "${length(var.endpoints)}"
  template = <<YAML
    {
      name  = "$${name}"
      value = "$${val}"
    }
YAML
  vars {
    name = "network-${count.index}"
    val = "${var.endpoints[count.index]}"
  }
}

output "demo" {
  value = "${data.template_file.ip_configuration.rendered}"
}

data "template_file" "ip_configuration" {
  template = <<YAML
    authorized_endpoints = [
      $${cidrs}
    ]
YAML
  vars {
    cidrs = "${join(",", var.endpoints)}"
  }
}