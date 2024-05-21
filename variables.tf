##Project##
variable "project_name" {
  type = string
}
variable "environment" {
  type = string
  default = "dev"
}
variable "comman_tags" {
    type = map
    default = {}
}

##VPC##
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "enabling_DNS_hostnames" {
  type = bool
  default = true
}

variable "vpc_tags" {
  type = map
  default = {}
}

##internet_gateway
variable "gw_tags" {
  type = map
  default = {}
}
##public-sunets
variable "public_subnet_cidrs" {
  type = list
  validation {
    ##we r passing cidrs in test module --if u dont give two cidrs, it will through error msg
    condition = length(var.public_subnet_cidrs) == 2
    error_message = "please give two public subnet cidrs"
  }
}

variable "public_subnet_cidrs_tags" {
  type = map
  default = {}
}
##private-subnets
variable "private_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.private_subnet_cidrs) == 2
    error_message = "please provide two private subnet cidrs"
  }
}

variable "private_subnet_cidrs_tags" {
  type = map
  default = {}
}
##database-subnets
variable "database_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.database_subnet_cidrs) == 2
    error_message = "please give two database subnet cidrs"
  }
}

variable "database_subnet_tags" {
  type = map
  default = {}
}

## database subnet group tags
variable "database_subnet_group_tags" {
  default = {}
}
##nat-gateway 
variable "nat_gateway_tags" {
  type = map
  default = {}
}

## peering connection
variable "is_peering_required" {
  type = bool
  default = false
}
variable "acceptor_vpc_id" {
  type = string
  default = ""
}
variable "vpc_peering_tags" {
  type = map
  default = {}
}