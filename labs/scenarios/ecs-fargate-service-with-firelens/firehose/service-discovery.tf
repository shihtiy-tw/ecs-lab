resource "aws_service_discovery_private_dns_namespace" "private" {
  name        = "${var.domain_name}-${var.scenario_name}"
  description = "Private dns namespace for service discovery"
  vpc         = data.aws_vpc.vpc.id
}

