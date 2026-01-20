# --- Artifact Registry: A private place to store our Docker images ---
resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repo_id
  format        = "DOCKER"
}