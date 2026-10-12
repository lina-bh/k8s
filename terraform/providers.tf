terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.12.0"
    }
    incus = {
      source  = "lxc/incus"
      version = "~> 1.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9"
    }
  }
}

provider "incus" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  default_remote = "melee"

  remote {
    name    = "melee"
    address = "https://melee.lamancha-alhena.ts.net:8443"
  }
}
