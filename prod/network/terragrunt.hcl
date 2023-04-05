include {
  path = find_in_parent_folders()
}

locals {
  locals_vars = read_terragrunt_config(find_in_parent_folders("locals.hcl"))
  common      = local.locals_vars.locals
}

terraform {
  source = "git::https://github.com/shoaib-mohiuddin/azure-mod-network"

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

inputs = {
  vnet_resource_group_name = "network-rg-${local.common.env}"
  location                 = "northeurope"
  address_space            = ["10.0.0.0/16"]
  subnet_address_prefixes  = ["10.0.0.0/23"]
  virtual_network_name     = "main-vnet-${local.common.env}"
  subnet_name              = "VmSubnet"
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