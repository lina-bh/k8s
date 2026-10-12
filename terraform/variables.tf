variable "nodes" {
  type = map(object({
    controlplane = bool
    host         = number
  }))
}

variable "ipv4cidr" {
  type = string

  validation {
    condition     = can(cidrnetmask(var.ipv4cidr))
    error_message = "must be valid ipv4 cidr"
  }
}

variable "cluster_name" {
  type = string
}

variable "talos_version" {
  type = string
}

variable "kubernetes_version" {
  type = string
}
