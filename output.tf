output "vpc1-public-vm-sg-id" {
  value = aws_security_group.vpc1_public_vm_sg.id
}

output "vpc2-private-vm-sg-id" {
  value = aws_security_group.vpc2_private_vm_sg.id
}