#!/bin/bash

# Replace these values with your actual ECR repository name and registry ID
repository_name="my-ecr-repo"
registry_id="137543238908"

# Fetch and delete images
image_ids=$(aws ecr list-images --repository-name $repository_name --registry-id $registry_id --query 'imageIds[*].imageDigest' --output json | jq -r '.[]')

for image_id in $image_ids; do
    aws ecr batch-delete-image --repository-name $repository_name --registry-id $registry_id --image-ids "imageDigest=$image_id"
done
