resource "aws_service_discovery_private_dns_namespace" "private" {
  name        = var.domain_name
  description = "Private dns namespace for service discovery"
  vpc         = data.aws_vpc.vpc.id
}

resource "aws_service_discovery_service" "this" {
  name = var.service_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private.id

    dns_records {
      ttl  = var.ttl
      type = var.type
    }

    routing_policy = var.routing_policy
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
