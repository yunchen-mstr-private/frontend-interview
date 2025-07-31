#!/bin/bash

# Docker Hub Push Script for Chat API

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

# Default values
DOCKER_USERNAME=""
IMAGE_NAME="chat-api"
TAG="latest"
VERSION=""

# Function to show help
show_help() {
    echo "Docker Hub Push Script for Chat API"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --username USERNAME    Docker Hub username (required)"
    echo "  -i, --image IMAGE_NAME     Image name (default: chat-api)"
    echo "  -t, --tag TAG              Tag (default: latest)"
    echo "  -v, --version VERSION      Version tag (optional)"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -u myusername                           # Push as myusername/chat-api:latest"
    echo "  $0 -u myusername -t v1.0.0                 # Push as myusername/chat-api:v1.0.0"
    echo "  $0 -u myusername -i my-chat-api -t stable  # Push as myusername/my-chat-api:stable"
    echo "  $0 -u myusername -v 1.0.0                  # Push both latest and v1.0.0 tags"
    echo ""
    echo "Environment Variables:"
    echo "  DOCKER_USERNAME            Docker Hub username (alternative to -u)"
    echo "  DOCKER_PASSWORD            Docker Hub password (for automated login)"
}

# Function to parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--username)
                DOCKER_USERNAME="$2"
                shift 2
                ;;
            -i|--image)
                IMAGE_NAME="$2"
                shift 2
                ;;
            -t|--tag)
                TAG="$2"
                shift 2
                ;;
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker is available"
}

# Function to check if user is logged in to Docker Hub
check_docker_login() {
    if ! docker info | grep -q "Username"; then
        print_warning "Not logged in to Docker Hub"
        
        # Try to use environment variable for password
        if [ ! -z "$DOCKER_PASSWORD" ]; then
            print_status "Attempting to login with environment variable..."
            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
        else
            print_status "Please login to Docker Hub:"
            docker login
        fi
    else
        print_success "Already logged in to Docker Hub"
    fi
}

# Function to validate username
validate_username() {
    if [ -z "$DOCKER_USERNAME" ]; then
        print_error "Docker Hub username is required!"
        echo "Use -u option or set DOCKER_USERNAME environment variable"
        exit 1
    fi
    
    # Check if username contains only valid characters
    if [[ ! "$DOCKER_USERNAME" =~ ^[a-z0-9_-]+$ ]]; then
        print_error "Invalid Docker Hub username: $DOCKER_USERNAME"
        print_error "Username must contain only lowercase letters, numbers, hyphens, and underscores"
        exit 1
    fi
}

# Function to build the Docker image
build_image() {
    local full_image_name="$DOCKER_USERNAME/$IMAGE_NAME:$TAG"
    
    print_status "Building Docker image for linux/amd64: $full_image_name"
    
    # Build the image for linux/amd64 platform
    docker build --platform linux/amd64 -t "$full_image_name" .
    
    # If version is specified, also tag with version
    if [ ! -z "$VERSION" ]; then
        local version_image_name="$DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
        print_status "Tagging with version: $version_image_name"
        docker tag "$full_image_name" "$version_image_name"
    fi
    
    print_success "Image built successfully for linux/amd64!"
}

# Function to push the Docker image
push_image() {
    local full_image_name="$DOCKER_USERNAME/$IMAGE_NAME:$TAG"
    
    print_status "Pushing image to Docker Hub: $full_image_name"
    
    # Push the main tag
    docker push "$full_image_name"
    
    # If version is specified, also push version tag
    if [ ! -z "$VERSION" ]; then
        local version_image_name="$DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
        print_status "Pushing version tag: $version_image_name"
        docker push "$version_image_name"
    fi
    
    print_success "Image pushed successfully to Docker Hub!"
}

# Function to show image information
show_image_info() {
    echo ""
    print_status "Image Information:"
    echo "  Username: $DOCKER_USERNAME"
    echo "  Image: $IMAGE_NAME"
    echo "  Tag: $TAG"
    echo "  Full name: $DOCKER_USERNAME/$IMAGE_NAME:$TAG"
    
    if [ ! -z "$VERSION" ]; then
        echo "  Version tag: $DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
    fi
    
    echo ""
    print_status "Pull commands:"
    echo "  docker pull $DOCKER_USERNAME/$IMAGE_NAME:$TAG"
    
    if [ ! -z "$VERSION" ]; then
        echo "  docker pull $DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
    fi
    
    echo ""
    print_status "Run commands:"
    echo "  docker run -d --name chat-api -p 3000:3000 $DOCKER_USERNAME/$IMAGE_NAME:$TAG"
    echo "  docker run -d --name chat-api -p 3000:3000 $DOCKER_USERNAME/$IMAGE_NAME:$TAG npm run dev"
}

# Function to test the pushed image
test_pushed_image() {
    local full_image_name="$DOCKER_USERNAME/$IMAGE_NAME:$TAG"
    
    print_status "Testing pushed image..."
    
    # Stop any existing container
    docker stop chat-api-test 2>/dev/null || true
    docker rm chat-api-test 2>/dev/null || true
    
    # Run the container
    docker run -d --name chat-api-test -p 3001:3000 "$full_image_name"
    
    # Wait for the service to start
    sleep 5
    
    # Test the health endpoint
    if curl -s http://localhost:3001/health > /dev/null; then
        print_success "Pushed image test passed!"
        print_status "API available at: http://localhost:3001"
        print_status "Swagger docs at: http://localhost:3001/api-docs"
    else
        print_error "Pushed image test failed!"
    fi
    
    # Clean up test container
    docker stop chat-api-test
    docker rm chat-api-test
}

# Function to create a pull script
create_pull_script() {
    local pull_script="pull-chat-api.sh"
    
    cat > "$pull_script" << EOF
#!/bin/bash

# Pull Chat API from Docker Hub
# Generated by push-to-dockerhub.sh

set -e

echo "🐳 Pulling Chat API from Docker Hub..."

# Pull the image
docker pull $DOCKER_USERNAME/$IMAGE_NAME:$TAG

echo "✅ Image pulled successfully!"
echo ""
echo "🚀 To run the container:"
echo "   docker run -d --name chat-api -p 3000:3000 $DOCKER_USERNAME/$IMAGE_NAME:$TAG"
echo ""
echo "📖 API Documentation:"
echo "   http://localhost:3000/api-docs"
echo "   http://localhost:3000/health"
EOF

    chmod +x "$pull_script"
    print_success "Created pull script: $pull_script"
}

# Main execution
main() {
    print_status "Starting Docker Hub push process..."
    
    # Parse command line arguments
    parse_args "$@"
    
    # Check prerequisites
    check_docker
    validate_username
    
    # Check Docker Hub login
    check_docker_login
    
    # Build and push
    build_image
    push_image
    
    # Show information
    show_image_info
    
    # Test the pushed image (optional)
    read -p "Do you want to test the pushed image? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        test_pushed_image
    fi
    
    # Create pull script
    create_pull_script
    
    print_success "Docker Hub push completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "  1. Share the pull script with others"
    echo "  2. Update your deployment scripts to use the new image"
    echo "  3. Consider setting up automated builds on Docker Hub"
}

# Run main function with all arguments
main "$@" 