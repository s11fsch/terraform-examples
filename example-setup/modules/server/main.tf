###
### SYS11 Terraform Example
### Module to create application server instances.
###

################################################################################
# Input variables
################################################################################

variable "num" {
  type    = string
  default = "1"
}

variable "name" {
  type = string
}

variable "syseleven_net" {
  type = string
}

variable "image" {
  type = string
}

variable "flavor" {
  type = string
}

variable "ssh_keys" {
  type = list(any)
}

variable "metadata" {
  type = map(any)
}

################################################################################
# Instances
################################################################################

resource "openstack_compute_instance_v2" "app_instances" {
  count       = var.num
  name        = "${var.name}${count.index}"
  image_id    = var.image
  flavor_name = var.flavor
  metadata    = var.metadata
  user_data = templatefile("${path.module}/cloud.cfg", {
    ssh_keys             = indent(8, "\n- ${join("\n- ", var.ssh_keys)}"),
    install_generic_sh   = base64encode(file("${path.module}/scripts/install_generic.sh")),
    install_appserver_sh = base64encode(file("${path.module}/scripts/install_appserver.sh"))
  })

  network {
    uuid = var.syseleven_net
  }

  lifecycle {
    ignore_changes = [
      image_id,
    ]
  }
}

################################################################################
# Output
################################################################################

output "instance_ip" {
  value = openstack_compute_instance_v2.app_instances.*.access_ip_v4
}
