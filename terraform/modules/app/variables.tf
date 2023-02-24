variable app_vms_count {
  type    = number
  default = 1
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
  default     = "~/.ssh/yc.pub"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default = "reddit-app-base"
}
variable subnet_id {
  description = "Subnet"
}
