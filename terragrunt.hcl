# This is the base config that will be applied for each level where we are terragrunting
# each configuration. Base provider, one for each level so a different key for each
#
# generated files
#    core.tf               Backend config
#    versions_override.tf  Terraform version, required providers
#    providers.tf          base provider blocks

locals {
  azurerm_version = "2.58.0"
}

remote_state {
  backend                         = "azurerm"
  disable_dependency_optimization = true
  generate = {
    path      = "core-generated.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate7fax4"
    container_name       = get_env("GIT_REPO_NAME", basename(get_parent_terragrunt_dir()))   # blob-tfstate7fax4
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">=0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>${local.azurerm_version}"
    }
  }
}
EOF
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF

provider "azurerm" {
  features {}
}
EOF
}