resource "azurerm_public_ip" "publicip_grupoc_mysql" {
    name                         = "myPublicIPMysql"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg_grupoc.name
    allocation_method            = "Static"
    idle_timeout_in_minutes = 30

    tags = {
        environment = "development"
    }

    depends_on = [ azurerm_resource_group.rg_grupoc ]
}

resource "azurerm_network_interface" "nic_grupoc_mysql" {
    name                      = "myNICMysql"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg_grupoc.name

    ip_configuration {
        name                          = "myNicConfigurationMysql"
        subnet_id                     = azurerm_subnet.subnet_grupoc.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.80.4.10"
        public_ip_address_id          = azurerm_public_ip.publicip_grupoc_mysql.id
    }

    tags = {
        environment = "development"
    }

    depends_on = [ azurerm_resource_group.rg_grupoc, azurerm_subnet.subnet_grupoc ]
}

resource "azurerm_network_interface_security_group_association" "nicsq_grupoc_mysql" {
    network_interface_id      = azurerm_network_interface.nic_grupoc_mysql.id
    network_security_group_id = azurerm_network_security_group.sg_grupoc.id

    depends_on = [ azurerm_network_interface.nic_grupoc_mysql, azurerm_network_security_group.sg_grupoc ]
}

data "azurerm_public_ip" "ip_grupoc_data_mysql" {
  name                = azurerm_public_ip.publicip_grupoc_mysql.name
  resource_group_name = azurerm_resource_group.rg_grupoc.name
}