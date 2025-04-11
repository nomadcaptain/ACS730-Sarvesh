output "public_webservers_ips" {
  value = slice(aws_instance.public_ec2[*].public_ip, 0, 2)
}

output "public_vm_ips" {
  value = slice(aws_instance.public_ec2[*].public_ip, 2, length(aws_instance.public_ec2[*].public_ip))
}

output "private_webservers_ips" {
  value = aws_instance.private_ec2[0].private_ip
}

output "private_vm_ips" {
  value = aws_instance.private_ec2[1].private_ip
}

output "public_vm_ids" {
  value = aws_instance.public_ec2[*].id
}