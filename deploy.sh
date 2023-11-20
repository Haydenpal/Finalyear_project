#!/bin/bash

# Set your AWS region and account ID
AWS_REGION="ap-south-1"  # Change this to your preferred AWS region
AWS_ACCOUNT_ID="137543238908"
ECR_REPO_NAME="my-ecr-repo"  # Change this to your desired repository name

# Initialize Terraform
terraform init

# Apply Terraform configuration
terraform apply -auto-approve

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push Docker image
DOCKER_IMAGE_NAME="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest"
docker build -t $ECR_REPO_NAME .
docker tag $ECR_REPO_NAME:latest $DOCKER_IMAGE_NAME
docker push $DOCKER_IMAGE_NAME

# Clean up - Uncomment the following lines if you want to destroy resources after pushing the image
#terraform destroy -auto-approve
