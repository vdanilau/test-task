output "azurerm_kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "azurerm_kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "azurerm_kubernetes_cluster_node_resource_group_name" {
  value = azurerm_kubernetes_cluster.k8s.node_resource_group
}

output "azurerm_kubernetes_cluster_kube_config" {
  sensitive = true
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw    
}