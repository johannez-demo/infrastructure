locals {
  service_name      = "demo"
  name_prefix       = "${local.service_name}-${terraform.workspace}"
  name_prefix_camel = "${title(local.service_name)}${title(terraform.workspace)}"
}
