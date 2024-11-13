#!/bin/bash

# Stop script on any error
set -e

# Authenticate Docker to AWS ECR
echo "Authenticating Docker with AWS ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build Docker image
echo "Building Docker image..."
docker build -t $ECR_REPOSITORY:$IMAGE_TAG ./api

# Tag the Docker image
echo "Tagging Docker image..."
docker tag $ECR_REPOSITORY:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG

# Push the Docker image to ECR
echo "Pushing Docker image to AWS ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG

# Update ECS task definition with new image
echo "Updating ECS task definition..."
TASK_DEFINITION_JSON=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION_NAME)
UPDATED_TASK_DEFINITION=$(echo $TASK_DEFINITION_JSON | jq \
  --arg IMAGE "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG" \
  '.taskDefinition | .containerDefinitions[0].image=$IMAGE | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities)')

echo $UPDATED_TASK_DEFINITION > new-task-def.json
NEW_TASK_DEF_ARN=$(aws ecs register-task-definition --cli-input-json file://new-task-def.json | jq -r '.taskDefinition.taskDefinitionArn')

# Update the ECS service to use the new task definition
echo "Updating ECS service to use new task definition..."
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $NEW_TASK_DEF_ARN

echo "Deployment to AWS ECS completed successfully!"
