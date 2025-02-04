output "project_number" {
  description = "The project number used in IAM conditions"
  value       = data.google_project.current.number
}

output "iam_bindings" {
  description = "The IAM conditional bindings created"
  value = {
    for binding in local.secret_manager_conditional_bindings : binding.title => {
      role        = binding.role
      members     = binding.members
      description = binding.description
      expression  = binding.expression
    }
  }
}