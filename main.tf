locals {
  ipv4cidr = "10.226.79.0/24"
}

module "terraform" {
  source = "./terraform"

  cluster_name       = "talos"
  talos_version      = "v1.14.2"
  kubernetes_version = "v1.37.0"

  ipv4cidr = local.ipv4cidr

  nodes = {
    "controlplane" = {
      controlplane = true,
      host         = -2,
    },
    "worker0" = {
      controlplane = false,
      host         = -3
    }
  }
}

output "talosconfig" {
  value     = module.terraform.talosconfig
  sensitive = true
}
