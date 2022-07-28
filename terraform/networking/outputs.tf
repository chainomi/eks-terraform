output "public_subnets_id" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "private_subnets_id" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "public_route_table" {
  value = aws_route_table.public.id
}

output "private_route_table" {
  value = aws_route_table.private.id
}


output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "public_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.public_subnet[*].id
}