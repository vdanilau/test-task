index = "01"
infrastructure_name = "sdtest"
location = "eastus2"
address_space_hub = ["10.0.0.0/24"]
address_space_spoke = ["10.0.1.0/24"]
vm_count = 3
allocation_method = "Static"
vpn_gateway_ip_sku = "Basic"

k8s_private_cluster_enabled = true
k8s_cluster_version = "1.19.11"
k8s_cluster_windows_node_pool = false
k8s_cluster_default_node_pool = {
  name               = "default"
  node_count         = 1
  vm_size            = "Standard_A2_v2"
  # availability_zones = ["1","2","3"]
  type               = "VirtualMachineScaleSets"
}

k8s_cluster_network_profile = {
  network_plugin     = "azure"
  network_policy     = "azure"
  dns_service_ip     = "10.0.8.10"
  docker_bridge_cidr = "172.17.0.1/16"
  service_cidr       = "10.0.8.0/24"
  load_balancer_sku  = "Standard"
}

k8s_cluster_identity = {
  type = "SystemAssigned"
}

k8s_private_cluster_admin_username = "admin"

dns_zone_name = "dan.devops-test-task-anfimau.de"
