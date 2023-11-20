# main.tf

provider "aws" {
  region = "ap-south-1"  # Change this to your preferred AWS region
}

resource "aws_ecr_repository" "my_ecr_repo" {
  name = "my-ecr-repo"  # Change this to your desired repository name
}

# Deploy script using null_resource
resource "null_resource" "deploy_script" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "./deploy.sh"
  }
}
