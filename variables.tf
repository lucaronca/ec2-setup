variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami" {
  type = map(string)
  default = {
    name  = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    owner = "099720109477" # Canonical
  }
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "security_group_name" {
  type    = string
  default = "app-security-group"
}

variable "cloudwatch_metric_alarm_period" {
  type    = string
  default = "3600" #seconds
}

variable "instance_tags" {
  type = map(string)
  default = {
    name        = "SERVER01"
    environment = "DEV"
    os          = "UBUNTU"
  }
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
