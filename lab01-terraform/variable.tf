variable "counts" {
  default = 1
}

variable "resource_group_name" {
  type = string
  description = "Name of Resource Group"
  default = "Lab01-RSG"
}

variable "resource_group_location" {
  type = string
  description = "Location of Resource Group"
  default = "centralus"
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
    default = "myFirs"
}

variable "image_resource_group" {
    type = string
    default = "Azuredevops"
}