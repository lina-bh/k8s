resource "talos_image_factory_schematic" "schematic" {
  schematic = yamlencode({
    customization = {
      extraKernelArgs = ["console=tty0"]
      systemExtensions = {
        officialExtensions = [
        ]
      }
    }
  })
}

data "talos_image_factory_urls" "image" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.schematic.id
  platform      = "metal"
  architecture  = "amd64"
}

resource "terraform_data" "iso" {
  lifecycle {
    create_before_destroy = true
  }

  input = "/var/tmp/${basename(data.talos_image_factory_urls.image.urls.iso)}"

  triggers_replace = data.talos_image_factory_urls.image.urls.iso

  provisioner "remote-exec" {
    connection {
      host        = "melee"
      private_key = file(pathexpand("~/.ssh/mele"))
    }

    inline = [
      "curl -fsSL -o ${self.output} ${data.talos_image_factory_urls.image.urls.iso}"
    ]
  }
}

resource "talos_machine_secrets" "secrets" {
  talos_version = "v1.14"
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
  nodes                = [for m in talos_machine.node : m.node]
  endpoints            = [for m in talos_machine.node : m.endpoint]
}
