locals {
  tag_name           = "titans"
  region             = "europe-west1"
  pod_range_name     = "pod-ip-range"
  service_range_name = "service-ip-range"
  project_name       = "playground-369107"
  services_to_enable = ["compute.googleapis.com", "container.googleapis.com"]
}

# Enable Needed Project Services
resource "google_project_service" "titans_project" {
  for_each = toset(local.services_to_enable)
  project  = local.project_name
  service  = each.value
}

# Titans Network(VPC)
resource "google_compute_network" "titans_network" {
  name                    = "${local.tag_name}-network"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.titans_project]
}

# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

# Titans Kubernetes Cluster
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"

  project_id                 = local.project_name
  name                       = "${local.tag_name}-cluster"
  region                     = local.region
  network                    = google_compute_network.titans_network.name
  subnetwork                 = google_compute_subnetwork.titans_subnet.name
  ip_range_pods              = local.pod_range_name
  ip_range_services          = local.service_range_name
  horizontal_pod_autoscaling = true

  zones = ["europe-west1-b", "europe-west1-c"]

  node_pools = [
    {
      name               = "${local.tag_name}-node-pool"
      machine_type       = "e2-medium"
      node_locations     = "europe-west1-b,europe-west1-c"
      min_count          = 2
      max_count          = 3
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.titans-sa.email
      preemptible        = true
      initial_node_count = 0
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

## Titans Cluster Node Service Account
resource "google_service_account" "titans-sa" {
  account_id   = "${local.tag_name}-sa"
  display_name = "Hands On"
}
