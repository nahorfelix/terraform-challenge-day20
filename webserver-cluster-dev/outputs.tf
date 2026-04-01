output "alb_dns_name" {
  description = "Open in browser (HTTP on port 80)."
  value       = aws_lb.public.dns_name
}

output "alb_url" {
  value = "http://${aws_lb.public.dns_name}"
}
