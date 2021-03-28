resource "azurerm_virtual_network" "vnet_grupoc" {
    name                = "myVnet"
    address_space       = ["10.80.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg_grupoc.name

    tags = {
        environment = "development"
    }

    depends_on = [ azurerm_resource_group.rg_grupoc ]
}

resource "azurerm_subnet" "subnet_grupoc" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.rg_grupoc.name
    virtual_network_name = azurerm_virtual_network.vnet_grupoc.name
    address_prefixes       = ["10.80.4.0/24"]

    depends_on = [ azurerm_resource_group.rg_grupoc, azurerm_virtual_network.vnet_grupoc ]
}

resource "azurerm_network_security_group" "sg_grupoc" {
    name                = "myNetworkSecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg_grupoc.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "MysqlPort"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "development"
    }

    depends_on = [ azurerm_resource_group.rg_grupoc ]
}