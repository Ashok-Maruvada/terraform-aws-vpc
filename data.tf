data "aws_availability_zones" "available" {
  state = "available"
}

# to get default vpc id
data "aws_vpc" "default" {
  default = true
}

# to get default vpc route table
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}