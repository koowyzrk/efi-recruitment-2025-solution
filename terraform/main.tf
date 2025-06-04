resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "default" {
  name         = "efi-recruitment-instance"
  machine_type = "e2-small"
  zone         = "europe-west3-b"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size = 20
    }
  }

  metadata = {
    ssh-keys = var.user_ssh_keys
  }
   tags = ["http-server", "https-server", "weatherapp"]

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${google_compute_address.static.address}"
    }
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_firewall" "allow_http_8000" {
  name    = "allow-http-8000"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["weatherapp"]
  description   = "Allow external access to port 8000"
}

output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

