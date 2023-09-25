variable "resource_group"{
    default = "CUSPRSGRPT01"
}
variable "virtual_network"{
    default = "CUSUPVNT01"
}
variable "subnet" {
    default = "APPUPSUB01"
}
variable "prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource name"
}