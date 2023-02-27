variable app_vms_count {
  type    = number
  default = 1
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
  default     = "~/.ssh/yc.pub"
}
variable private_key_path {
  default = "~/.ssh/yc"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default = "reddit-app-base"
}
variable subnet_id {
  description = "Subnet"
}
variable "database_url" {
  description = "DB for reddit app"
}
variable folder_id {
  description = "Folder"
}
