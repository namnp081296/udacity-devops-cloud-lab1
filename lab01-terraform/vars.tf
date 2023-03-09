variable "counts" {
  default = 1
}

variable "resource_group_name" {
  type = string
  description = "Name of Resource Group"
  default = "Azuredevops"
}

variable "resource_group_location" {
  type = string
  description = "Location of Resource Group"
  default = "West Europe"
}

variable "size_vm" {
  type = string
  default = "Standard_B1s" 
}

variable "admin_usr" {
  type = string
  default = "namnp"
}

variable "admin_pwd" {
  type = string
  default = "Admin1234!@#$"
}

variable "image_name" {
    type = string
    default = "Lab01-image"
}

variable "image_resource_group" {
    type = string
    default = "Azuredevops"
}

variable "availability_set_name" {
    type = string
    default = "Lab01AvailabilitySet"
}