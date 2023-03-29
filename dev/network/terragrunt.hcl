include {
  path = find_in_parent_folders()
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
  vnet_resource_group_name = "network-rg"
  location = "West Europe"
  address_space = ["10.0.0.0/16"]
  subnet_address_prefixes = ["10.0.1.0/23"]
  virtual_network_name = "main-vnet"
  subnet_name = "VmSubnet"
  tags = {
    environment = "dev"
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