output "azurerm_key_vault_certificate_base64" {
  sensitive = true
  value = azurerm_key_vault_certificate.certificate.certificate_data_base64
}