# --------------------------------------------------
# Project and billing
# --------------------------------------------------

resource "google_project" "app" {
  project_id      = var.project_id
  name            = var.project_id
  billing_account = var.billing_account_id

  auto_create_network = false

  lifecycle {
    prevent_destroy = true
  }
}

# --------------------------------------------------
# Enable required APIs
# --------------------------------------------------

locals {
  required_apis = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "sts.googleapis.com",
  ])
}

resource "google_project_service" "apis" {
  for_each = local.required_apis

  project            = google_project.app.project_id
  service            = each.value
  disable_on_destroy = false
}

# --------------------------------------------------
# Artifact Registry
# --------------------------------------------------

resource "google_artifact_registry_repository" "docker" {
  project       = google_project.app.project_id
  location      = var.region
  repository_id = var.artifact_repo
  description   = "Docker repository for SvelteKit app"
  format        = "DOCKER"

  depends_on = [
    google_project_service.apis
  ]
}

# --------------------------------------------------
# GitHub Actions service account
# --------------------------------------------------

resource "google_service_account" "github_actions" {
  project      = google_project.app.project_id
  account_id   = var.service_account_name
  display_name = "GitHub Actions Service Account"
  description  = "Used by GitHub Actions via Workload Identity Federation"

  depends_on = [
    google_project_service.apis
  ]
}

# Artifact Registry write access
resource "google_project_iam_member" "artifact_writer" {
  project = google_project.app.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Cloud Run deployment access
resource "google_project_iam_member" "cloud_run_developer" {
  project = google_project.app.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Allow the GitHub Actions identity to impersonate
# the GitHub Actions service account.
resource "google_service_account_iam_member" "github_actions_wif" {
  service_account_id = google_service_account.github_actions.name

  role = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}

# Allow deployment SA to attach the default Compute Engine
# service account as the Cloud Run runtime identity.
resource "google_service_account_iam_member" "compute_service_account_user" {
  service_account_id = "projects/${google_project.app.project_id}/serviceAccounts/${google_project.app.number}-compute@developer.gserviceaccount.com"

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

# --------------------------------------------------
# Cloud Run runtime service account
# --------------------------------------------------

resource "google_service_account" "cloud_run_runtime" {
  project      = google_project.app.project_id
  account_id   = "cloud-run-runtime"
  display_name = "Cloud Run Runtime Service Account"
  description  = "Identity used by the running Cloud Run application"
}

# --------------------------------------------------
# Workload Identity Pool
# --------------------------------------------------

resource "google_iam_workload_identity_pool" "github" {
  project                   = google_project.app.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Pool for GitHub Actions OIDC authentication"
  mode                      = "FEDERATION_ONLY"

  depends_on = [
    google_project_service.apis
  ]
}

# --------------------------------------------------
# GitHub OIDC provider
# --------------------------------------------------

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = google_project.app.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id

  display_name = "GitHub OIDC Provider"
  description  = "GitHub Actions OIDC authentication"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = <<-EOT
    assertion.repository == "${var.github_repo}" &&
    assertion.ref == "refs/heads/${var.github_branch}"
  EOT

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_service_account_iam_member" "github_actions_runtime_user" {
  service_account_id = google_service_account.cloud_run_runtime.name

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_cloud_run_v2_service" "app" {
  project  = var.project_id
  name     = var.cloud_run_service
  location = var.region

  description = "SvelteKit application: ${var.cloud_run_service}"
  ingress     = "INGRESS_TRAFFIC_ALL"

  # Protect against accidental deletion in production.
  deletion_protection = true

  template {
    service_account = google_service_account.cloud_run_runtime.email

    timeout = "60s"

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      # Bootstrap image only. GitHub Actions must deploy the real app.
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }

  lifecycle {
    # gcloud run deploy / CI is the source of truth for the image.
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }

  depends_on = [
    google_project_service.apis,
    google_service_account_iam_member.github_actions_runtime_user,
  ]
}

# --------------------------------------------------
# Make Cloud Run service publicly accessible
# --------------------------------------------------

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = google_cloud_run_v2_service.app.project
  location = google_cloud_run_v2_service.app.location
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
