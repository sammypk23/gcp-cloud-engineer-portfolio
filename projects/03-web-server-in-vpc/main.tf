# --- Provider Configuration ---
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  project = "project-86a83b40-693f-4462-a18"
  region  = "us-central1"
}

# --- Network Resources ---
resource "google_compute_network" "the_fortress_vpc" {
  name                    = "the-fortress-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet-us-east4"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east4"
  network       = google_compute_network.the_fortress_vpc.id
}

# --- NEW: Dedicated Service Account for the Web Server ---
# This gives our VM its own unique identity.
resource "google_service_account" "web_server_sa" {
  account_id   = "web-server-sa"
  display_name = "Web Server Service Account"
}

# --- MODIFIED: Firewall Rule now targets the Service Account ---
resource "google_compute_firewall" "allow_http" {
  name    = "the-fortress-allow-http"
  network = google_compute_network.the_fortress_vpc.id
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  # This is the change! We are targeting the VM's identity, not a tag.
  target_service_accounts = [google_service_account.web_server_sa.email]
}

 # This allows us to connect to the VM using the "SSH" button in the console.
    resource "google_compute_firewall" "allow_iap_ssh" {
      name    = "the-fortress-allow-iap-ssh"
      network = google_compute_network.the_fortress_vpc.id
      
      allow {
        protocol = "tcp"
        ports    = ["22"] # Port 22 is for SSH
      }

      # This is a special IP range owned by Google for the IAP service.
      source_ranges = ["35.235.240.0/20"]
    }

# --- MODIFIED: Compute Instance now uses the Service Account ---
# --- Compute Instance using Service Account and file() function ---
    resource "google_compute_instance" "web_server" {
      name         = "lighthouse-vm"
      machine_type = "e2-micro"
      zone         = "us-east4-a"
      
      boot_disk {
        initialize_params {
          image = "debian-cloud/debian-11"
        }
      }

      network_interface {
        subnetwork = google_compute_subnetwork.private_subnet.id
        access_config {}
      }

      # This block assigns the service account identity to the VM.
      service_account {
        email  = google_service_account.web_server_sa.email
        scopes = ["cloud-platform"]
      }

      # Use the file() function for a robust script definition.
      metadata_startup_script = file("startup.sh")
    }

# --- Output Block (Unchanged) ---
output "web_server_ip" {
  description = "The public IP address of the web server."
  value       = google_compute_instance.web_server.network_interface[0].access_config[0].nat_ip
}