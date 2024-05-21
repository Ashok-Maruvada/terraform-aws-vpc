locals {
  resource_name = "${var.project_name}-${var.environment}"
  #using slice function, taking first two zones i.e 1a and 1b
  #mention impicit index which starts with index '0' and other is explicit index which shows how many indeces u want starting from '0'
  az_names = slice(data.aws_availability_zones.available.names, 0, 2)
}