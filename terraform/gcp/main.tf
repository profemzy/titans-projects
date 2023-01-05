terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
  backend "gcs" {
    bucket = "titans-ops-terraform-state"
    prefix = "handson"
  }
}

provider "google" {
  # Configuration options
  project = "playground-369107"
  region  = "europe-west1"
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}
