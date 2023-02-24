variable app_vms_count {
  type    = number
  default = 1
}
variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
  default     = "~/.ssh/yc.pub"
}
variable private_key_path {
  default = "~/.ssh/yc"
}
variable image_id {
  description = "Disk image"
}
variable network_id {
  description = "Network"
}
variable subnet_id {
  description = "Subnet"
}
variable token {
  description = "key .json"
}
