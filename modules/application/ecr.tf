resource "aws_ecr_repository" "service" {
  for_each = toset(var.service_names)

  name                 = "${var.environment}-${each.value}"
  image_tag_mutability = "IMMUTABLE"
}