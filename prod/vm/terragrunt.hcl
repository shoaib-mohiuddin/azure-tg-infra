include {
  path = find_in_parent_folders()
}

locals {
  locals_vars = read_terragrunt_config(find_in_parent_folders("locals.hcl"))
  common      = local.locals_vars.locals
}

terraform {
  source = "git::https://github.com/shoaib-mohiuddin/azure-mod-compute"

  before_hook "echo_module" {
    commands = get_terraform_commands_that_need_locking()
    execute = [
      "echo",
      "\n\n",
      "--------------",
      "\n\n",
      "Deploying ${get_original_terragrunt_dir()}",
      "\n\n",
      "--------------",
      "\n\n",
    ]
  }

  after_hook "output_plan" {
    commands = ["plan"]
    execute  = ["sh", "-c", "terraform show tfplan"]
  }
}

dependency "networking" {
  config_path = "../network"
}

dependencies {
  paths = ["../network"]
}

inputs = {
  location     = "northeurope"
  rg_name      = "webserver-rg-${local.common.env}"
  vm_name      = "webserver-${local.common.env}"
  vm_size      = "Standard_D4s_v4"
  vm_subnet_id = dependency.networking.outputs.vm_subnet_id
  tags = {
    environment = "${local.common.env}"
    foo = "bar"
  }
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