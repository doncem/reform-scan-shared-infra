provider "azurerm" {
  alias           = "mgmt"
  subscription_id = "${var.mgmt_subscription_id}"
  version         = "=1.42.0"
}

locals {
  stripped_product  = "${replace(var.product, "-", "")}"
  account_name      = "${local.stripped_product}${var.env}"
  mgmt_network_name = "${var.subscription == "prod" || var.subscription == "nonprod" ? "mgmt-infra-prod" : "mgmt-infra-sandbox"}"
  prod_hostname     = "${local.stripped_product}.${var.external_hostname}"
  nonprod_hostname  = "${local.stripped_product}.${var.env}.${var.external_hostname}"
  external_hostname = "${ var.env == "prod" ? local.prod_hostname : local.nonprod_hostname}"

  // for each client service two containers are created: one named after the service
  // and another one, named {service_name}-rejected, for storing envelopes rejected by process
  client_containers = ["bulkscan", "cmc", "crime", "divorce", "finrem", "probate", "sscs"]
}

data "azurerm_subnet" "trusted_subnet" {
  name                 = "${local.trusted_vnet_subnet_name}"
  virtual_network_name = "${local.trusted_vnet_name}"
  resource_group_name  = "${local.trusted_vnet_resource_group}"
}

data "azurerm_subnet" "jenkins_subnet" {
  provider             = "azurerm.mgmt"
  name                 = "jenkins-subnet"
  virtual_network_name = "${local.mgmt_network_name}"
  resource_group_name  = "${local.mgmt_network_name}"
}

resource "azurerm_storage_account" "storage_account" {
  name                = "${local.account_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"

  custom_domain {
    name          = "${local.external_hostname}"
    use_subdomain = "false"
  }

  network_rules {
    virtual_network_subnet_ids = ["${data.azurerm_subnet.trusted_subnet.id}", "${data.azurerm_subnet.jenkins_subnet.id}"]
    bypass                     = ["Logging", "Metrics", "AzureServices"]
    default_action             = "Deny"
  }

  tags = "${local.tags}"
}

resource "azurerm_storage_container" "client_containers" {
  name                 = "${local.client_containers[count.index]}"
  storage_account_name = "${azurerm_storage_account.storage_account.name}"
  count                = "${length(local.client_containers)}"
}

resource "azurerm_storage_container" "client_rejected_containers" {
  name                 = "${local.client_containers[count.index]}-rejected"
  storage_account_name = "${azurerm_storage_account.storage_account.name}"
  count                = "${length(local.client_containers)}"
}

# store blob storage secrets in key vault
resource "azurerm_key_vault_secret" "storage_account_name" {
  key_vault_id = "${data.azurerm_key_vault.key_vault.id}"
  name         = "storage-account-name"
  value        = "${azurerm_storage_account.storage_account.name}"
}

resource "azurerm_key_vault_secret" "storage_account_primary_key" {
  key_vault_id = "${data.azurerm_key_vault.key_vault.id}"
  name         = "storage-account-primary-key"
  value        = "${azurerm_storage_account.storage_account.primary_access_key}"
}

resource "azurerm_key_vault_secret" "storage_account_secondary_key" {
  key_vault_id = "${data.azurerm_key_vault.key_vault.id}"
  name         = "storage-account-secondary-key"
  value        = "${azurerm_storage_account.storage_account.secondary_access_key}"
}
