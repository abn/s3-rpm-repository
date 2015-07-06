variable "access_key" {}
variable "secret_key" {}
variable "bucket" {}

variable "region" {
    default = "ap-southeast-2"
}

variable "ami" {
    default = "ami-01136d3b"
}

variable "key_file" {
    default = "~/.ssh/id_rsa.pub"
}

variable "prefix" {
    default = "s3_private_yum_repo"
}
