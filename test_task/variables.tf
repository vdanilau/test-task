variable "index" {
  type        = string
  description = "The index of the resources created in the specified Azure Resource Group"
}

variable "infrastructure_name" {
  type        = string
  description = "The prefix for the resources created in the specified Azure Resource Group"
}

variable "location" {
  type        = string
  description = "The location for the deployment"
}

variable "address_space_hub" {
  type        = list(string)
  description = "Address space for infrastructure."
}

variable "address_space_spoke" {
  type        = list(string)
  description = "Address space for infrastructure."
}

variable "allocation_method" {
  type        = string
  description = "Allocation method of public IP"
}

variable "vpn_gateway_ip_sku" {
  type        = string
  description = "SKU of public IP"
}

variable "k8s_cluster_version" {
  type        = string
}

variable "k8s_private_cluster_enabled" {
  type        = string
}

variable "k8s_cluster_default_node_pool" {
  type        = map
}

variable "k8s_cluster_network_profile" {
  type        = map
}

variable "k8s_cluster_identity" {
  type        = map
}

variable "k8s_private_cluster_admin_username" {
  type        = string
}

variable "dns_zone_name" {
  type        = string
}

variable "k8s_cluster_windows_node_pool" {
  type        = string
}