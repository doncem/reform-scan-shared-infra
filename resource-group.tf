locals {
  product = "reform-scan"
  tags        = "${merge(
    var.common_tags,
    map(
      "Team Contact", "#rbs",
      "Team Name", "Bulk Scan"
    ))}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-v2-${var.env}"
  location = "${var.location}"

  tags = "${local.tags}"
}

resource "azurerm_resource_group" "reform_scan_rg" {
  name     = "${local.product}-v2-${var.env}"
  location = "${var.location}"

  tags = "${local.tags}"
}
