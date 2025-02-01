# GCP Secret Manager IAM Configuration

This Terraform configuration manages IAM permissions for multiple team when using  Google Cloud Secret Manager.

## Prerequisites

1. Create a GCP Project if it not already exist ( a dedicated project for secret manager is recommended)
2. Create a GCP Service Account with appropriate permissions to run this terraform code 
3. Download the service account key JSON file (but DO NOT commit it to Git!) either name it as `terraform-service-account-key.json` (excluded this in .gitignore already) keep it outside of your git repo 
4. Set up authentication using one of these methods:

### Option 1: Environment Variable (Recommended for local development)
```bash
export GOOGLE_CREDENTIALS=$(cat path/to/terraform-service-account-key.json)
```

### Option 2: Application Default Credentials
```bash
gcloud auth application-default login
```

### Option 3: CI/CD Environment Variables
For GitHub Actions, set the `GOOGLE_CREDENTIALS` secret in your repository settings with the service account key JSON content.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values as appropraite 
2. You may need to tune the `.gitignore` file to include the tfvars files as necessary if you commit to personal repo to track changes
3. Initialize Terraform:
```bash
terraform init
```

4. Plan the changes:
```bash
terraform plan -var-file=manifests/terraform.tfvars
```

5. Apply the changes:
```bash
terraform apply
```

## TO DO 
- Modify to safely handle (non authoritative) other binding for the same principle and role
- List minimal IAM permissions for the terraform service account to perfrom this work
- List of API needed 
    - Cloud Resource Manager API
    - 