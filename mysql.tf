resource "azurerm_storage_account" "storage_grupoc_mysql" {
    name                        = "grupocstoragemysql"
    resource_group_name         = azurerm_resource_group.rg_grupoc.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "development"
    }

    depends_on = [ azurerm_resource_group.rg_grupoc ]
}

resource "azurerm_linux_virtual_machine" "vm_grupoc_mysql" {
    name                  = "grupocvmmysql"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg_grupoc.name
    network_interface_ids = [azurerm_network_interface.nic_grupoc_mysql.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "grupoCOSDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"

    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvmmysql"
    admin_username = var.user
    admin_password = var.password
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storage_grupoc_mysql.primary_blob_endpoint
    }

    tags = {
        environment = "development"
    }

    depends_on = [ azurerm_resource_group.rg_grupoc, azurerm_network_interface.nic_grupoc_mysql, azurerm_storage_account.storage_grupoc_mysql, azurerm_public_ip.publicip_grupoc_mysql ]
}

resource "time_sleep" "wait_30_seconds_mysql" {
  depends_on = [azurerm_linux_virtual_machine.vm_grupoc_mysql]
  create_duration = "30s"
}

resource "null_resource" "upload_mysql" {
    provisioner "file" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = data.azurerm_public_ip.ip_grupoc_data_mysql.ip_address
        }
        source = "mysql"
        destination = "/home/grupoc"
    }

    depends_on = [ time_sleep.wait_30_seconds_mysql ]
}

resource "null_resource" "deploy_mysql" {
    triggers = {
        order = null_resource.upload_mysql.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = data.azurerm_public_ip.ip_grupoc_data_mysql.ip_address
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y mysql-server-5.7",
            "sudo mysql < /home/grupoc/mysql/script/user.sql",
            "sudo mysql < /home/grupoc/mysql/script/schema.sql",
            "sudo mysql < /home/grupoc/mysql/script/data.sql",
            "sudo cp -f /home/grupoc/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf",
            "sudo service mysql restart",
            "sleep 20",
        ]
    }
}