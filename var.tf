variable "region" {
    default="ap-south-1"
}
variable "vpc" {
    default="10.0.0.0/16"
}
variable "vpc-name" {
    default="my-vpc"
}
variable "enable_dns_support" {
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
}
variable "public" {
    default="10.0.1.0/24"
}
variable "zone1" {
    default="ap-south-1a"
}
variable "subnet1" {
    default="public"
}
variable "private" {
    default="10.0.2.0/24"
}
variable "zone2" {
    default="ap-south-1b"
}
variable "subnet2" {
    default="private"
}
variable "myig" {
default="my-ig1"
}
variable "route" {
    default="0.0.0.0/0"
}

variable "ami" {
    default="ami-0f58b397bc5c1f2e8"
}
variable "type" {
    default="t2.medium"
}
variable "key" {
    default="aws"
}
variable "instance1" {
    default="web-server-public"
}
variable "instance2" {
    default="web-server-private"
}
