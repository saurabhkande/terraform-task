
# Create the ECR repository

resource "aws_ecr_repository" "ssk_ecr_repo" {
  name = var.ecr-repo  
  tags = {
    Name = "ssk-ecr"
  }
  image_tag_mutability = "MUTABLE"  # Allow overwriting of tags
}

