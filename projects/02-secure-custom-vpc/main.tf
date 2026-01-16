# --- Provider Configuration  ---
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  # Remember to replace this with your actual Project ID
  project = "project-86a83b40-693f-4462-a18"
  region  = "us-east4"
}

# --- Network Resources ---

# 1. The VPC Network itself
# This is the main container for our secure network.
resource "google_compute_network" "the_fortress_vpc" {
  name                    = "the-fortress-vpc"
  # This is a crucial setting. We are telling Google NOT to create any default subnets or firewall rules.
  # We want full manual control for maximum security.
  auto_create_subnetworks = false
}

# 2. A Subnet within the VPC
# This defines a private IP address range for our resources within a specific region.
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet-us-east4"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east4"
  # This links the subnet to the VPC we created above. This is a dependency.
  network       = google_compute_network.the_fortress_vpc.id
}

# 3. A Firewall Rule
# This is a foundational security rule. It denies all incoming traffic from anywhere
# to any instance in our network, unless another rule specifically allows it.
resource "google_compute_firewall" "deny_all_ingress" {
  name    = "the-fortress-deny-all-ingress"
  # Apply this rule to the VPC we created.
  network = google_compute_network.the_fortress_vpc.id
  
  # A high priority number means it runs first.
  priority = 1000

  # The "deny" block.
  deny {
    protocol = "all"
  }

  # Apply to all sources.
  source_ranges = ["0.0.0.0/0"]
}