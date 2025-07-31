#!/bin/bash

# Chat API Docker Management Script

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

# Function to build the Docker image
build_image() {
    print_status "Building Chat API Docker image for linux/amd64..."
    docker build --platform linux/amd64 -t chat-api:latest .
    print_success "Docker image built successfully for linux/amd64!"
}

# Function to run the container
run_container() {
    print_status "Starting Chat API container..."
    docker run -d \
        --name chat-api-service \
        -p 3000:3000 \
        -e NODE_ENV=production \
        -e PORT=3000 \
        --restart unless-stopped \
        chat-api:latest
    print_success "Container started successfully!"
    print_status "API available at: http://localhost:3000"
    print_status "Swagger docs at: http://localhost:3000/api-docs"
}

# Function to run with docker-compose
run_compose() {
    print_status "Starting Chat API with docker-compose..."
    docker-compose up -d
    print_success "Services started successfully!"
    print_status "API available at: http://localhost:3000"
    print_status "Swagger docs at: http://localhost:3000/api-docs"
}

# Function to run development environment
run_dev() {
    print_status "Starting Chat API in development mode..."
    docker-compose -f docker-compose.dev.yml up -d
    print_success "Development services started successfully!"
    print_status "API available at: http://localhost:3000"
    print_status "Swagger docs at: http://localhost:3000/api-docs"
    print_warning "Development mode with hot reload enabled"
}

# Function to stop containers
stop_containers() {
    print_status "Stopping Chat API containers..."
    docker-compose down 2>/dev/null || true
    docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
    docker stop chat-api-service 2>/dev/null || true
    docker rm chat-api-service 2>/dev/null || true
    print_success "Containers stopped successfully!"
}

# Function to show logs
show_logs() {
    print_status "Showing container logs..."
    docker-compose logs -f chat-api 2>/dev/null || docker logs -f chat-api-service 2>/dev/null || print_error "No running containers found"
}

# Function to show container status
show_status() {
    print_status "Container status:"
    docker ps --filter "name=chat-api" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Function to clean up
cleanup() {
    print_status "Cleaning up Docker resources..."
    stop_containers
    docker rmi chat-api:latest 2>/dev/null || true
    docker system prune -f
    print_success "Cleanup completed!"
}

# Function to test the API
test_api() {
    print_status "Testing API endpoints..."
    
    # Wait a moment for the service to start
    sleep 3
    
    # Test health endpoint
    if curl -s http://localhost:3000/health > /dev/null; then
        print_success "Health check passed!"
    else
        print_error "Health check failed!"
        return 1
    fi
    
    # Test Swagger docs
    if curl -s http://localhost:3000/api-docs > /dev/null; then
        print_success "Swagger docs accessible!"
    else
        print_error "Swagger docs not accessible!"
        return 1
    fi
    
    print_success "API testing completed!"
}

# Function to show help
show_help() {
    echo "Chat API Docker Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build     Build the Docker image"
    echo "  run       Run the container directly"
    echo "  compose   Run with docker-compose (production)"
    echo "  dev       Run in development mode with hot reload"
    echo "  stop      Stop all containers"
    echo "  logs      Show container logs"
    echo "  status    Show container status"
    echo "  test      Test the API endpoints"
    echo "  cleanup   Clean up all Docker resources"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 compose"
    echo "  $0 dev"
    echo "  $0 test"
}

# Main script logic
case "${1:-help}" in
    build)
        build_image
        ;;
    run)
        build_image
        run_container
        ;;
    compose)
        build_image
        run_compose
        ;;
    dev)
        build_image
        run_dev
        ;;
    stop)
        stop_containers
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    test)
        test_api
        ;;
    cleanup)
        cleanup
        ;;
    help|*)
        show_help
        ;;
esac 