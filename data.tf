data "aws_availability_zones" "availability" {
    state = "available"
}

data "aws_vpc" "default" {
  default = true
}