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
      members     = ["${value.iam_member}"]
      title       = "allow-to-${key}-deny-others"
      description = "Allow access to ${value.allowed_secret_prefix} secrets and deny access to other secrets"
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

# Create IAM bindings directly 
resource "google_project_iam_binding" "secret_manager_conditional" {
  for_each = {
    for binding in local.secret_manager_conditional_bindings : binding.title => binding
  }

  project = var.project_id
  role    = each.value.role

  members = each.value.members

  condition {
    title       = each.value.title
    description = each.value.description
    expression  = each.value.expression
  }
}