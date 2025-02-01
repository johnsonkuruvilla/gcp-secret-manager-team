locals {
  # Check for required environment variables and multiple file locations
  credentials_file = try(pathexpand(coalesce(
    # First try environment variable
    try(nonsensitive(coalesce(var.GOOGLE_CREDENTIALS_FILE, "")), null),
    # Then try local service account key file
    fileexists("${path.root}/terraform-service-account-key.json") ? "${path.root}/terraform-service-account-key.json" : null,
    # Finally try parent directory
    fileexists("${path.root}/../terraform-service-account-key.json") ? "${path.root}/../terraform-service-account-key.json" : null
  )), null)

  # Read and validate credentials file if it exists
  credentials = local.credentials_file != null ? (
    fileexists(local.credentials_file) ? file(local.credentials_file) : null
  ) : null

  # Check for credentials in environment variable
  has_credentials = local.credentials != null || can(nonsensitive(coalesce(var.GOOGLE_CREDENTIALS, "")))
}

# Validate credentials are available
resource "null_resource" "credentials_check" {
  lifecycle {
    precondition {
      condition     = local.has_credentials
      error_message = "GCP credentials not found. Please set GOOGLE_CREDENTIALS environment variable with the service account key JSON content or GOOGLE_CREDENTIALS_FILE pointing to the key file, or place terraform-service-account-key.json in the current or parent directory."
    }
  }
}