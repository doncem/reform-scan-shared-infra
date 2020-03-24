module "queue-namespace" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace?ref=master"
  name                = "${local.product}-servicebus-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.reform_scan_rg.name}"
  env                 = "${var.env}"
  common_tags         = "${var.common_tags}"
}

module "notifications-queue" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=master"
  name                = "notifications"
  namespace_name      = "${module.queue-namespace.name}"
  resource_group_name = "${azurerm_resource_group.reform_scan_rg.name}"
  lock_duration       = "PT5M"

  duplicate_detection_history_time_window = "PT15M"
}

resource "azurerm_key_vault_secret" "notifications_queue_send_conn_str" {
  key_vault_id = "${data.azurerm_key_vault.key_vault.id}"
  name         = "notifications-queue-send-connection-string"
  value        = "${module.notifications-queue.primary_send_connection_string}"
}

resource "azurerm_key_vault_secret" "notifications_queue_listen_conn_str" {
  key_vault_id = "${data.azurerm_key_vault.key_vault.id}"
  name         = "notifications-queue-listen-connection-string"
  value        = "${module.notifications-queue.primary_listen_connection_string}"
}

module "notifications-queue-aat-staging" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=master"
  name                = "notifications-aat-staging"
  namespace_name      = "${module.queue-namespace.name}"
  resource_group_name = "${azurerm_resource_group.reform_scan_rg.name}"
  lock_duration       = "PT5M"

  duplicate_detection_history_time_window = "PT15M"
  queue_enabled       = "${var.env == "aat" ? "true" : "false" }"
}

resource "azurerm_key_vault_secret" "notifications_queue_aat_staging_send_conn_str" {
  key_vault_id = "${data.azurerm_key_vault.key_vault.id}"
  name         = "notifications-queue-aat-staging-send-connection-string"
  value        = "${module.notifications-queue-aat-staging.primary_send_connection_string}"
  count        =  "${var.env == "aat" ? 1 : 0 }"
}

resource "azurerm_key_vault_secret" "notifications_queue_aat_staging_listen_conn_str" {
  key_vault_id = "${data.azurerm_key_vault.key_vault.id}"
  name         = "notifications-queue-aat-staging-listen-connection-string"
  value        = "${module.notifications-queue-aat-staging.primary_listen_connection_string}"
  count        =  "${var.env == "aat" ? 1 : 0 }"
}