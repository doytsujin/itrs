variable "region" {
  default = "eu-west-3"
}
variable "AmiLinux" {
  type = "map"
  default = {
    eu-west-1 = "ami-9398d3e0"
    eu-west-3 = "ami-4f55e332"
  }
  description = "I add only 2 regions to show the map feature but you can add all the regions"
}
variable "aws_access_key" {
  default = ""
  description = "The user aws access key. Not saved to git for security reasons."
}
variable "aws_secret_key" {
  default = ""
  description = "The user aws secret key. Not saved to git for security reasons."
}
variable "vpc-fullcidr" {
    default = "172.28.0.0/16"
  description = "the vpc cdir"
}
variable "Subnet-Public-AzA-CIDR" {
  default = "172.28.0.0/24"
  description = "the cidr of the subnet"
}
variable "Subnet-Private-AzA-CIDR" {
  default = "172.28.3.0/24"
  description = "the cidr of the subnet"
}
variable "key_name" {
  default = "itrs"
  description = "the ssh key to use in the EC2 machines"
}
variable "DnsZoneName" {
  default = "itrs.local"
  description = "the internal domain name"
} 
