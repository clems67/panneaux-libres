variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = "panneaux-libres-391284"
}

variable "billing_account_id" {
  description = "Google Cloud billing account ID"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format"
  type        = string
  default     = "clems67/panneaux-libres"
}

variable "github_branch" {
  description = "Branch allowed to deploy through GitHub Actions"
  type        = string
  default     = "main"
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "europe-west9"
}

variable "artifact_repo" {
  description = "Artifact Registry Docker repository name"
  type        = string
  default     = "sveltekit-repo"
}

variable "pool_id" {
  description = "Workload Identity Pool ID"
  type        = string
  default     = "github-pool"
}

variable "provider_id" {
  description = "Workload Identity Provider ID"
  type        = string
  default     = "github-provider"
}

variable "service_account_name" {
  description = "GitHub Actions deployment service account name"
  type        = string
  default     = "github-actions-sa"
}

variable "cloud_run_service" {
  description = "Cloud Run instance"
  type        = string
  default     = "cloud-run-service"
}
