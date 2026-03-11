output "public_ip" {
  value       = aws_instance.app_vm.public_ip
  description = "Public IP of app server"
}

output "public_dns" {
  value       = aws_instance.app_vm.public_dns
  description = "Public DNS of app server"
}
