# VPC 생성
resource "google_compute_network" "web_vpc" {
  name                    = "web-vpc"
  description             = "web service Network"
  auto_create_subnetworks = false
}

# 서울 서브넷 (Public)
resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-1"
  region        = var.region_seoul
  network       = google_compute_network.web_vpc.id
  ip_cidr_range = "192.168.1.0/24"
}

# 오레곤 서브넷 (Private)
resource "google_compute_subnetwork" "subnet_2" {
  name          = "subnet-2"
  region        = var.region_oregon
  network       = google_compute_network.web_vpc.id
  ip_cidr_range = "10.0.0.0/24"
}

# 방화벽: External -> Web (22, 80)
resource "google_compute_firewall" "allow_ssh_web" {
  name    = "allow-ssh-web"
  network = google_compute_network.web_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# 방화벽: Web Subnet -> WAS Subnet (SSH)
resource "google_compute_firewall" "allow_ssh_was" {
  name    = "allow-ssh-was"
  network = google_compute_network.web_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["192.168.1.0/24"]
  target_tags   = ["was-server"]
}

# Cloud NAT (오레곤용)
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  region  = var.region_oregon
  network = google_compute_network.web_vpc.id
}

resource "google_compute_router_nat" "was_nat" {
  name                               = "was-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region_oregon
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnet_2.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}