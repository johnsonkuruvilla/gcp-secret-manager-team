data "google_project" "current" {
  project_id = var.project_id
}

locals {
  # Format the project path using project number
  secret_path = "projects/${data.google_project.current.number}/secrets"
  
  # Transform the secret manager teams into the format expected by conditional_bindings
  secret_manager_conditional_bindings = [
    for key, value in var.secret_manager_teams : {
      role        = var.role
      title       = "allow-to-${key}-secrets-deny-others"
      description = "Allow access to ${value.allowed_secret_prefix} secrets and deny access to other team secrets"
      members     = [value.iam_member]
          expression  = <<-EOT
        (resource.name.startsWith("${local.secret_path}/${value.allowed_secret_prefix}")) ||
        (
          ${join(" && \n", [
            for prefix in value.denied_secret_prefixes :
           "!(resource.name.startsWith(\"${local.secret_path}/${prefix}\"))"
          ])}
        )
      EOT 
    }
  ]
}

module "project-iam" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 8.0"

  projects = [var.project_id]

  conditional_bindings = local.secret_manager_conditional_bindings

  depends_on = [
    null_resource.credentials_check,
    data.google_project.current
  ]
}