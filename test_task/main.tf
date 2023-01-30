terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "2.94.0"
        }
    }
}

provider "azurerm" {
    features {}
}

module "azure_resource_group" {
  source   = "../modules/azure_rg"
  name     = "${var.infrastructure_name}-${var.index}"
  location = var.location
}

module "azure_key_vault" {
  source              = "../modules/azure_key_vault"
  name                = "${var.infrastructure_name}-kv-${var.index}"
  location            = var.location
  resource_group_name = module.azure_resource_group.rg_name_output
}

module "certificate" {
  source              = "../modules/certificate"
  name                = "certificate01"
  key_vault_id        = module.azure_key_vault.key_vault_id_output
}

# Get certificate data from KV
data "azurerm_key_vault_secret" "certificate" {
  name         = "certificate01"
  key_vault_id = module.azure_key_vault.key_vault_id_output
}

module "azure_virtual_network_vpn_gateway" {
    source              = "../modules/azure_vnet"
    name                = "${var.infrastructure_name}-hub_vnet-${var.index}"
    location            = var.location
    address_space       = var.address_space_hub
    resource_group_name = module.azure_resource_group.rg_name_output
}

module "azure_subnet_vpn_gateway" {
    source               = "../modules/azure_subnet"
    name                 = "${var.infrastructure_name}-hub_subnet-${var.index}"
    address_prefix       = [cidrsubnet(element(var.address_space_hub, 0), 8, 0)]
    virtual_network_name = module.azure_virtual_network_vpn_gateway.virtual_network_name_output
    resource_group_name  = module.azure_resource_group.rg_name_output
}

module "azure_virtual_network_spoke" {
    source              = "../modules/azure_vnet"
    name                = "${var.infrastructure_name}-spoke_vnet-${var.index}"
    location            = var.location
    address_space       = var.address_space_spoke
    resource_group_name = module.azure_resource_group.rg_name_output
}

module "azure_subnet_spoke" {
    source               = "../modules/azure_subnet"
    name                 = "${var.infrastructure_name}-client-${var.index}"
    address_prefix       = [cidrsubnet(element(var.address_space_spoke, 0), 8, 0)]
    virtual_network_name = module.azure_virtual_network_spoke.virtual_network_name_output
    resource_group_name  = module.azure_resource_group.rg_name_output
}

module "azure_virtual_network_peering" {
  source                    = "../modules/azure_vnet_peering"
  name                      = "${var.infrastructure_name}-peer-${var.index}"
  resource_group_name       = module.azure_resource_group.rg_name_output
  virtual_network_name      = module.azure_virtual_network_spoke.virtual_network_name_output
  remote_virtual_network_id = module.azure_virtual_network_vpn_gateway.virtual_network_id_output
}

module "azure_public_ip_vpn_gateway" {
    source              = "../modules/azure_public_ip"
    name                = "${var.infrastructure_name}-pip-${var.index}"
    location            = var.location
    resource_group_name = module.azure_resource_group.rg_name_output
    allocation_method   = var.allocation_method
    sku                 = var.vpn_gateway_ip_sku
}

module "azure_vpn_gateway" {
  source                               = "../modules/azure_vpn_gateway"
  name                                 = "${var.infrastructure_name}-vpngateway-${var.index}"
  location                             = var.location
  resource_group_name                  = module.azure_resource_group.rg_name_output
  azure_subnet_id                      = module.azure_subnet_vpn_gateway.subnet_id_output
  public_ip_address_id                 = module.azure_public_ip_vpn_gateway.puplic_ip_id_output
  address_space                        = [cidrsubnet(element(var.address_space_spoke, 0), 8, 0)]
  certificate_data_base64              = module.certificate.azurerm_key_vault_certificate_base64
}

module "azure_kubernetes_cluster" {
  source                         = "../modules/azure_kubernetes_cluster"
  providers = {
    azurerm = azurerm
  }
  
  k8s_cluster_name                                            = "${var.infrastructure_name}-aks-cluster-${var.index}"
  location                                                    = var.location
  k8s_cluster_resource_group_name                             = module.azure_resource_group.rg_name_output
  k8s_cluster_node_resource_group                             = module.azure_resource_group.rg_name_output
  k8s_cluster_private_dns_prefix                              = "${var.infrastructure_name}-aks_cluster-${var.index}"
  k8s_cluster_version                                         = var.k8s_cluster_version
  k8s_private_cluster_enabled                                 = var.k8s_private_cluster_enabled
  k8s_cluster_default_node_pool                               = var.k8s_cluster_default_node_pool
  k8s_cluster_default_node_pool_vnet_subnet_id                = module.azure_subnet_spoke.subnet_id_output
  k8s_cluster_network_profile                                 = var.k8s_cluster_network_profile
  k8s_cluster_windows_node_pool                               = var.k8s_cluster_windows_node_pool
  k8s_cluster_identity                                                = var.k8s_cluster_identity
  k8s_cluster_admin_username                                  = var.k8s_private_cluster_admin_username
  azurerm_key_vault_id                                        = module.azure_key_vault.key_vault_id_output
}

module "azure_dns_zone"{
    source = "../modules/azure_dns_zone"
    dns_zone_name = var.dns_zone_name
    resource_group_name = module.azure_resource_group.rg_name_output
}