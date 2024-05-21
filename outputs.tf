# output "azs" {
#   value = data.aws_availability_zones.available.names
# }

output "vpc_id" {
  value = aws_vpc.main.id
}

# whatever the outputs, declared here (by module developers) -- will going to catch by module users