locals {
  name_prefix        = "ta"
  env                = basename(get_terragrunt_dir())
  hosts_suffix       = "${local.env}-"
}
