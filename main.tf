# 서울 웹서버 외부 IP 예약
resource "google_compute_address" "web_server_eip" {
  name   = "web-server-eip"
  region = var.region_seoul
}

# Task 4: Web Server (Rocky Linux 9)
resource "google_compute_instance" "web_vm" {
  name         = "web-vm"
  machine_type = "e2-medium"
  zone         = var.zone_seoul
  tags         = ["web-server"]

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-9"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_1.id
    access_config {
      nat_ip = google_compute_address.web_server_eip.address
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    dnf -y install httpd
    systemctl enable httpd && systemctl start httpd
    HOSTNAME=$(hostname)
    EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
    cat <<HTML > /var/www/html/index.html
    <html><body style="font-family:Arial;text-align:center;margin-top:100px;">
    <div style="display:inline-block;padding:40px;border-radius:20px;box-shadow:0 0 15px rgba(0,0,0,0.1);">
    <h1 style="color:#D73B3E;">🔥 Apache on GCP (Terraform) 🔥</h1>
    <p><b>Hostname:</b> $HOSTNAME</p>
    <p><b>External IP:</b> $EXTERNAL_IP</p>
    </div></body></html>
    HTML
  EOF
}

# Task 9: Private WAS Server (Ubuntu 24.04)
resource "google_compute_instance" "was_vm" {
  name         = "was-vm"
  machine_type = "e2-standard-2"
  zone         = var.zone_oregon
  tags         = ["was-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_2.id
    # 외부 IP 없음 (Private)
  }
}

output "web_public_ip" {
  value = google_compute_address.web_server_eip.address
}