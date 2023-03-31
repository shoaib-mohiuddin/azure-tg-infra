include {
  path = find_in_parent_folders()
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
  location     = "West Europe"
  rg_name      = "webserver-rg"
  vm_name      = "webserver"
  vm_subnet_id = dependency.networking.outputs.vm_subnet_id.id
  tags = {
    environment = "dev"
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