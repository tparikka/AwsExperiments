# outputs.tf

# Returns the Application Load Balancer (ALB) host name
output "alb_hostname" {
  value = "${aws_alb.main.dns_name}:${local.container_port}"
}