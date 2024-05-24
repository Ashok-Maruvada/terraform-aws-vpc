# output "azs" {
#   value = data.aws_availability_zones.available.names
# }

output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_ids" {
  value = aws_subnet.public.id
}
output "private_subnet_ids" {
  value = aws_subnet.private.id
}
output "db_subnet_ids" {
  value = aws_subnet.database.id
}

# whatever the outputs, declared here (by module developers) -- will going to catch by module users