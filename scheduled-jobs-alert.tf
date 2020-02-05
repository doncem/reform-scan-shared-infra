module "blob-dispatcher-alert" {
  source            = "git@github.com:hmcts/cnp-module-metric-alert"
  location          = "${azurerm_application_insights.appinsights.location}"
  app_insights_name = "${azurerm_application_insights.appinsights.name}"

  enabled    = "${var.env == "prod"}"
  alert_name = "Reform_Blob_Dispatcher_-_BSP"
  alert_desc = "Triggers when no logs from blob-dispatcher job found within timeframe."

  app_insights_query = "traces | where message startswith 'Started blob-dispatcher job'"

  frequency_in_minutes       = 30
  time_window_in_minutes     = 30
  severity_level             = "1"
  action_group_name          = "${module.alert-action-group.action_group_name}"
  custom_email_subject       = "Reform Scan blob-dispatcher"
  trigger_threshold_operator = "Equal"
  trigger_threshold          = 0
  resourcegroup_name         = "${azurerm_resource_group.rg.name}"
}

module "delete-dispatched-files-alert" {
  source            = "git@github.com:hmcts/cnp-module-metric-alert"
  location          = "${azurerm_application_insights.appinsights.location}"
  app_insights_name = "${azurerm_application_insights.appinsights.name}"

  enabled    = "${var.env == "prod"}"
  alert_name = "Reform_Delete_Dispatched_Files_-_BSP"
  alert_desc = "Triggers when no logs from delete-dispatched-files job found within timeframe."

  app_insights_query = "traces | where message startswith 'Started delete-dispatched-files job'"

  frequency_in_minutes       = 120
  time_window_in_minutes     = 120
  severity_level             = "1"
  action_group_name          = "${module.alert-action-group.action_group_name}"
  custom_email_subject       = "Reform Scan delete-dispatched-files"
  trigger_threshold_operator = "Equal"
  trigger_threshold          = 0
  resourcegroup_name         = "${azurerm_resource_group.rg.name}"
}

module "handle-rejected-files-alert" {
  source            = "git@github.com:hmcts/cnp-module-metric-alert"
  location          = "${azurerm_application_insights.appinsights.location}"
  app_insights_name = "${azurerm_application_insights.appinsights.name}"

  enabled    = "${var.env == "prod"}"
  alert_name = "Reform_Handle_Rejected_Files_-_BSP"
  alert_desc = "Triggers when no logs from handle-rejected-files job found within timeframe."

  app_insights_query = "traces | where message startswith 'Started handle-rejected-files job'"

  frequency_in_minutes       = 120
  time_window_in_minutes     = 120
  severity_level             = "1"
  action_group_name          = "${module.alert-action-group.action_group_name}"
  custom_email_subject       = "Reform Scan handle-rejected-files"
  trigger_threshold_operator = "Equal"
  trigger_threshold          = 0
  resourcegroup_name         = "${azurerm_resource_group.rg.name}"
}
