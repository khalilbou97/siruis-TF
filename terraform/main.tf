

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_resource_group" "rg" {
  name      = "pfe-v2"
  location  = "francecentral"
}



resource "azurerm_service_plan" "back" {
  name                = "back-plan-auto"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "francecentral"
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_linux_web_app" "back" {
  name                = "backpfe97-app-service-auto"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.back.location
  service_plan_id     = azurerm_service_plan.back.id

  site_config {
    application_stack {
      java_server = "JAVA"
      java_version="11-java11"
        }
    cors  {
      allowed_origins     = ["https://frontpfe97-app-service-auto.azurewebsites.net"]
      support_credentials = true
    }
  }
  
}

resource "azurerm_linux_web_app" "keycloak" {
  name                = "keycloackpfe97-app-service-auto"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.back.location
  service_plan_id     = azurerm_service_plan.back.id

  site_config {
    application_stack {
      docker_image = "khalilbou97/keycloak"
      docker_image_tag="latest"
    }
  }
  app_settings = {
    "KEYCLOAK_PASSWORD"           = "admin"
    "KEYCLOAK_USER"                = "admin"
    "WEBSITES_PORT"           = "8080"
    "PROXY_ADDRESS_FORWARDING" = "true"
    }
    
  
}

resource "azurerm_service_plan" "front" {
  name                = "front-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "francecentral"
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "front" {
  name                = "frontpfe97-app-service-auto"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.back.location
  service_plan_id     = azurerm_service_plan.back.id

  site_config {
    app_command_line = "pm2 serve /home/site/wwwroot --no-daemon --spa"
    application_stack {
      node_version = "16-lts"

    }
    cors  {
      allowed_origins     = ["https://backpfe97-app-service-auto.azurewebsites.net","https://keycloackpfe97-app-service-auto.azurewebsites.net"]
      support_credentials = true
    }

  }
  
}