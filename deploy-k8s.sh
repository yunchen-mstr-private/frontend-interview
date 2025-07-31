#!/bin/bash

# Kubernetes Deployment Script for Chat API

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if kubectl is installed
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    print_success "kubectl is available"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker is available"
}

# Function to build and push Docker image
build_and_push_image() {
    local registry=$1
    local image_name=$2
    
    print_status "Building Docker image for linux/amd64..."
    docker build --platform linux/amd64 -t $image_name:latest .
    
    if [ ! -z "$registry" ]; then
        print_status "Tagging image for registry: $registry"
        docker tag $image_name:latest $registry/$image_name:latest
        
        print_status "Pushing image to registry..."
        docker push $registry/$image_name:latest
        
        print_success "Image pushed to registry: $registry/$image_name:latest"
    else
        print_success "Image built locally: $image_name:latest"
    fi
}

# Function to deploy to Kubernetes
deploy_to_k8s() {
    local image_name=$1
    
    print_status "Creating namespace..."
    kubectl apply -f k8s/namespace.yaml
    
    print_status "Creating configmap..."
    kubectl apply -f k8s/configmap.yaml
    
    print_status "Deploying application..."
    kubectl apply -f k8s/deployment.yaml
    
    print_status "Creating service..."
    kubectl apply -f k8s/service.yaml
    
    print_status "Creating ingress..."
    kubectl apply -f k8s/ingress.yaml
    
    print_success "Deployment completed!"
}

# Function to check deployment status
check_deployment() {
    print_status "Checking deployment status..."
    
    echo ""
    print_status "Pods:"
    kubectl get pods -n chat-api
    
    echo ""
    print_status "Services:"
    kubectl get services -n chat-api
    
    echo ""
    print_status "Ingress:"
    kubectl get ingress -n chat-api
}

# Function to show logs
show_logs() {
    print_status "Showing pod logs..."
    kubectl logs -f deployment/chat-api -n chat-api
}

# Function to scale deployment
scale_deployment() {
    local replicas=$1
    print_status "Scaling deployment to $replicas replicas..."
    kubectl scale deployment chat-api --replicas=$replicas -n chat-api
    print_success "Deployment scaled to $replicas replicas"
}

# Function to delete deployment
delete_deployment() {
    print_warning "This will delete all Chat API resources from Kubernetes!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deleting deployment..."
        kubectl delete -f k8s/ingress.yaml --ignore-not-found=true
        kubectl delete -f k8s/service.yaml --ignore-not-found=true
        kubectl delete -f k8s/deployment.yaml --ignore-not-found=true
        kubectl delete -f k8s/configmap.yaml --ignore-not-found=true
        kubectl delete -f k8s/namespace.yaml --ignore-not-found=true
        print_success "Deployment deleted!"
    else
        print_status "Deletion cancelled"
    fi
}

# Function to show help
show_help() {
    echo "Chat API Kubernetes Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  deploy [registry] [image-name]  Deploy to Kubernetes"
    echo "  status                          Check deployment status"
    echo "  logs                            Show pod logs"
    echo "  scale <replicas>                Scale deployment"
    echo "  delete                          Delete deployment"
    echo "  help                            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy                                    # Deploy with local image"
    echo "  $0 deploy gcr.io/my-project chat-api        # Deploy with GCR registry"
    echo "  $0 deploy my-registry.com chat-api          # Deploy with custom registry"
    echo "  $0 scale 5                                   # Scale to 5 replicas"
    echo "  $0 status                                    # Check status"
    echo "  $0 delete                                    # Delete deployment"
}

# Main script logic
case "${1:-help}" in
    deploy)
        check_kubectl
        check_docker
        
        registry=${2:-""}
        image_name=${3:-"chat-api"}
        
        build_and_push_image "$registry" "$image_name"
        deploy_to_k8s "$image_name"
        check_deployment
        ;;
    status)
        check_kubectl
        check_deployment
        ;;
    logs)
        check_kubectl
        show_logs
        ;;
    scale)
        check_kubectl
        replicas=${2:-1}
        scale_deployment "$replicas"
        ;;
    delete)
        check_kubectl
        delete_deployment
        ;;
    help|*)
        show_help
        ;;
esac 