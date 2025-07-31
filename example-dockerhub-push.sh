#!/bin/bash

# Example: How to push Chat API to Docker Hub

echo "🐳 Docker Hub Push Examples for Chat API"
echo "========================================"
echo ""

# Example 1: Basic push with username
echo "Example 1: Basic push to Docker Hub"
echo "-----------------------------------"
echo "./push-to-dockerhub.sh -u yourusername"
echo ""

# Example 2: Push with custom tag
echo "Example 2: Push with custom tag"
echo "-------------------------------"
echo "./push-to-dockerhub.sh -u yourusername -t v1.0.0"
echo ""

# Example 3: Push with custom image name
echo "Example 3: Push with custom image name"
echo "--------------------------------------"
echo "./push-to-dockerhub.sh -u yourusername -i my-chat-api -t stable"
echo ""

# Example 4: Push with both latest and version tags
echo "Example 4: Push with both latest and version tags"
echo "------------------------------------------------"
echo "./push-to-dockerhub.sh -u yourusername -v 1.0.0"
echo ""

# Example 5: Using environment variables
echo "Example 5: Using environment variables"
echo "-------------------------------------"
echo "export DOCKER_USERNAME=yourusername"
echo "export DOCKER_PASSWORD=yourpassword"
echo "./push-to-dockerhub.sh"
echo ""

# Example 6: Using npm scripts
echo "Example 6: Using npm scripts"
echo "----------------------------"
echo "npm run dockerhub:push -- -u yourusername"
echo "npm run dockerhub:help"
echo ""

echo "📋 Steps to push to Docker Hub:"
echo "1. Create a Docker Hub account at https://hub.docker.com"
echo "2. Login to Docker Hub: docker login"
echo "3. Run one of the examples above"
echo "4. Share the generated pull script with others"
echo ""

echo "🔗 After pushing, your image will be available at:"
echo "https://hub.docker.com/r/yourusername/chat-api"
echo ""

echo "📖 For more options, run:"
echo "./push-to-dockerhub.sh --help" 