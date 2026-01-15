# This block tells Terraform which providers we need. In this case, we need the Google Cloud provider.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0" # Using a specific version is a best practice
    }
  }
}

# This block configures the Google Cloud provider.
# You need to tell it which project and region to work in.
provider "google" {
  # --- IMPORTANT ---
  # Replace "your-gcp-project-id" with your actual Google Cloud Project ID.
  # You can find this on the main dashboard of the Google Cloud Console.
  project = "project-86a83b40-693f-4462-a18"
  region  = "us-east4"
}

# This is the main part: the "resource" block.
# It tells Terraform that we want to create a Google Compute Engine virtual machine.
resource "google_compute_instance" "hello_world_vm" {
  # The name of the VM that will be created in Google Cloud.
  name         = "hello-world-vm"

  # The type of machine to create. "e2-micro" is part of the Always Free tier!
  machine_type = "e2-micro"

  # The zone to create the VM in. This must be within the provider's region.
  zone         = "us-east4-a"

  # Defines the boot disk for the VM (the operating system).
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Defines the network interface. This allows the VM to connect to the network.
  # The "default" network is automatically created in every GCP project.
  network_interface {
    network = "default"
  }
}