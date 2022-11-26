# Titans Sub-Network
resource "google_compute_subnetwork" "titans_subnet" {
  name          = "${local.tag_name}-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = local.region
  network       = google_compute_network.titans_network.id
  secondary_ip_range {
    range_name    = local.pod_range_name
    ip_cidr_range = "192.168.10.0/24"
  }
  secondary_ip_range {
    range_name    = local.service_range_name
    ip_cidr_range = "192.168.20.0/24"
  }
}

# Titans Firewall
resource "google_compute_firewall" "default" {
  name    = "${local.tag_name}-firewall"
  network = google_compute_network.titans_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "31079", "31457"]
  }

  source_ranges = ["0.0.0.0/0"]
}
