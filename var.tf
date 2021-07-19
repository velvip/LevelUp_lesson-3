variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "192.168.0.0/16"
}
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "192.168.0.0/24"
}
variable "availability_zone" {
  description = "availability zone to create subnet"
  default     = "eu-west-2a"
}
variable "backend_count" {
  default = 2
}
