variable "location" {
  default = "East US 2"
}

variable "resource_group_name" {
  default = "rg-epicbook-prod"
}

variable "vm_name" {
  default = "vm-epicbook"
}

variable "admin_username" {
  default = "azureuser"
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}

variable "admin_ssh_cidr" {
  description = "Public IP address allowed to access the VM over SSH, in CIDR notation."
  type        = string
}