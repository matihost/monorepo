resource "azurerm_monitor_action_group" "email-notification" {
  name                = "${local.prefix}-default"
  resource_group_name = local.resource_group_name

  # max 12 characters
  short_name = local.prefix

  enabled = var.alert_email != ""

  email_receiver {
    name                    = "default"
    email_address           = var.alert_email != "" ? var.alert_email : "dummy@dummy-non-existing-email-address.com"
    use_common_alert_schema = true
  }

}
