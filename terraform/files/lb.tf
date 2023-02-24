resource "yandex_alb_load_balancer" "reddit-app-balancer" {
  name = "reddit-app-balancer"

  network_id = var.network_id

  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = var.subnet_id
    }
  }

  listener {
    name = "reddit-app-listener"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.reddit-app-http-router.id
      }
    }
  }
}

resource "yandex_alb_http_router" "reddit-app-http-router" {
  name = "reddit-app-http-router"
}

resource "yandex_alb_virtual_host" "reddit-app-virtual-host" {
  name           = "reddit-app-virtual-host"
  http_router_id = yandex_alb_http_router.reddit-app-http-router.id

  route {
    name = "main-route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.reddit-app-backend-group.id
        timeout          = "10s"
      }
    }
  }
}

resource "yandex_alb_backend_group" "reddit-app-backend-group" {
  name = "reddit-app-backend-group"

  http_backend {
    name             = "reddit-app-http-backend"
    weight           = 1
    port             = 9292
    target_group_ids = [yandex_alb_target_group.reddit-app-target-group.id]
    http2            = false

    load_balancing_config {
      panic_threshold = 0
    }

    healthcheck {
      timeout  = "1s"
      interval = "1s"

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_target_group" "reddit-app-target-group" {
  name = "reddit-app-target-group"

  # создать блок target для каждого экземпляра приложения
  dynamic "target" {
    for_each = yandex_compute_instance.app

    content {
      subnet_id  = var.subnet_id
      ip_address = target.value["network_interface"].0.ip_address
    }
  }
}

output "external_ip_address_app_balancer" {
  value = yandex_alb_load_balancer.reddit-app-balancer.listener.0.endpoint.0.address.0.external_ipv4_address
}
