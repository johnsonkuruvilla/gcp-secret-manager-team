variable "project_id" {
  description = "The GCP project ID where the secrets will be stored"
  type        = string
}

variable "secret_manager_teams" {
  description = "Map of teams and their allowed and denied  secret prefixes"
  type = map(object({
    iam_member              = string
    allowed_secret_prefix   = string
    denied_secret_prefixes  = list(string)
  }))
}

variable "role" {
  description = "The IAM role to assign to each team "
  type        = string
  default     = "roles/secretmanager.admin"
}

variable "GOOGLE_CREDENTIALS" {
  description = "Google Cloud credentials JSON content"
  type        = string
  default     = null
  sensitive   = true
}

variable "GOOGLE_CREDENTIALS_FILE" {
  description = "Path to Google Cloud credentials file"
  type        = string
  default     = null
}