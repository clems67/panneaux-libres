output "project_id" {
  description = "Google Cloud project ID"
  value       = google_project.app.project_id
}

output "project_number" {
  description = "Google Cloud project number"
  value       = google_project.app.number
}

output "artifact_registry_repository" {
  description = "Artifact Registry Docker repository URL"
  value       = "${var.region}-docker.pkg.dev/${google_project.app.project_id}/${google_artifact_registry_repository.docker.repository_id}"
}

output "workload_identity_provider" {
  description = "Full Workload Identity Provider resource name"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "github_actions_service_account" {
  description = "GitHub Actions service account email"
  value       = google_service_account.github_actions.email
}

output "cloud_run_region" {
  description = "Cloud Run deployment region"
  value       = var.region
}