resource "incus_server" "melee" {
  config = {}
}

resource "incus_network" "incusbr0" {
  lifecycle {
    destroy = false
  }

  name = "incusbr0"
}

resource "incus_storage_pool" "dir" {
  name   = "dir"
  driver = "dir"

  config = {
    source = "/var/lib/incus/storage-pools/dir"
  }
}
