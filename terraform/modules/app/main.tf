data "yandex_compute_image" "app-image" {
  family = var.app_disk_image
  folder_id = var.folder_id
}

resource "yandex_compute_instance" "app" {
  name  = format("reddit-app-%d", count.index)
  count = var.app_vms_count

  labels = {
    tags = "reddit-app"
  }

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.app-image.id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/puma.service.tftpl", {
      database_url: var.database_url,
    })
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
}
