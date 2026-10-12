resource "incus_instance" "node" {
  for_each = var.nodes

  name = each.key
  type = "virtual-machine"
  wait_for { type = "ipv4" }

  config = {
    "security.secureboot" = false
    "limits.memory"       = each.value.controlplane ? "2GiB" : "2GiB"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path            = "/"
      pool            = incus_storage_pool.dir.name
      size            = "10GiB"
      "boot.priority" = 10
    }
  }

  device {
    name = "iso"
    type = "disk"
    properties = {
      source          = resource.terraform_data.iso.output
      "boot.priority" = 5
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = incus_network.incusbr0.name
      "ipv4.address" = cidrhost(var.ipv4cidr, each.value.host)
    }
  }
}

data "talos_machine_configuration" "node" {
  for_each = var.nodes

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${incus_instance.node[each.key].ipv4_address}:6443"
  machine_type       = each.value.controlplane ? "controlplane" : "worker"
  machine_secrets    = talos_machine_secrets.secrets.machine_secrets
  talos_version      = talos_machine_secrets.secrets.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = [
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "UnattendedInstallConfig"
      installer = {
        image = data.talos_image_factory_urls.image.urls.installer
      }
      provisioning = {
        diskSelector = {
          match = "disk.dev_path == \"/dev/sda\""
        }
        wipe = true
      }
    })
  ]
}

resource "talos_machine" "node" {
  for_each = incus_instance.node

  node                     = each.key
  endpoint                 = each.value.ipv4_address
  client_configuration_wo  = talos_machine_secrets.secrets.client_configuration
  machine_configuration_wo = data.talos_machine_configuration.node[each.key].machine_configuration
  image                    = data.talos_image_factory_urls.image.urls.installer

  drain_on_upgrade = false
  # kubeconfig_wo    = talos_cluster_kubeconfig.machine[each.key].kubeconfig_raw
}
