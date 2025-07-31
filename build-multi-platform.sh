#!/bin/bash

# Multi-Platform Docker Build Script for Chat API

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
IMAGE_NAME="chat-api"
TAG="latest"
PLATFORMS="linux/amd64,linux/arm64"
PUSH_TO_REGISTRY=""
BUILDX_AVAILABLE=false

# Function to show help
show_help() {
    echo "Multi-Platform Docker Build Script for Chat API"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --image IMAGE_NAME     Image name (default: chat-api)"
    echo "  -t, --tag TAG              Tag (default: latest)"
    echo "  -p, --platforms PLATFORMS  Platforms to build (default: linux/amd64,linux/arm64)"
    echo "  -r, --registry REGISTRY    Push to registry after build"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Build for linux/amd64,linux/arm64"
    echo "  $0 -p linux/amd64                     # Build only for linux/amd64"
    echo "  $0 -i my-chat-api -t v1.0.0          # Custom image name and tag"
    echo "  $0 -r myusername                      # Build and push to Docker Hub"
    echo "  $0 -p linux/amd64 -r myusername      # Build amd64 and push to Docker Hub"
    echo ""
    echo "Platforms:"
    echo "  linux/amd64    - Intel/AMD 64-bit"
    echo "  linux/arm64    - ARM 64-bit (Apple Silicon, ARM servers)"
    echo "  linux/arm/v7   - ARM 32-bit v7"
    echo "  linux/386      - Intel 32-bit"
}

# Function to parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--image)
                IMAGE_NAME="$2"
                shift 2
                ;;
            -t|--tag)
                TAG="$2"
                shift 2
                ;;
            -p|--platforms)
                PLATFORMS="$2"
                shift 2
                ;;
            -r|--registry)
                PUSH_TO_REGISTRY="$2"
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

# Function to check if Docker Buildx is available
check_buildx() {
    if docker buildx version &> /dev/null; then
        BUILDX_AVAILABLE=true
        print_success "Docker Buildx is available"
    else
        print_warning "Docker Buildx is not available. Using standard docker build for single platform."
        BUILDX_AVAILABLE=false
    fi
}

# Function to create buildx builder if needed
setup_buildx() {
    if [ "$BUILDX_AVAILABLE" = true ]; then
        print_status "Setting up Docker Buildx builder..."
        
        # Check if builder exists
        if ! docker buildx inspect multi-platform-builder &> /dev/null; then
            print_status "Creating multi-platform builder..."
            docker buildx create --name multi-platform-builder --use
        else
            print_status "Using existing multi-platform builder..."
            docker buildx use multi-platform-builder
        fi
        
        # Bootstrap the builder
        docker buildx inspect --bootstrap
    fi
}

# Function to build single platform (fallback)
build_single_platform() {
    local platform=$1
    local image_name="$IMAGE_NAME:$TAG"
    
    print_status "Building for platform: $platform"
    
    # Extract platform architecture for tagging
    local arch=$(echo $platform | cut -d'/' -f2)
    local tagged_image="${IMAGE_NAME}:${TAG}-${arch}"
    
    docker build --platform $platform -t $tagged_image .
    
    if [ ! -z "$PUSH_TO_REGISTRY" ]; then
        local registry_image="$PUSH_TO_REGISTRY/$tagged_image"
        print_status "Tagging for registry: $registry_image"
        docker tag $tagged_image $registry_image
        
        print_status "Pushing to registry: $registry_image"
        docker push $registry_image
    fi
    
    print_success "Built and pushed: $tagged_image"
}

# Function to build multi-platform
build_multi_platform() {
    local image_name="$IMAGE_NAME:$TAG"
    
    print_status "Building multi-platform image: $image_name"
    print_status "Platforms: $PLATFORMS"
    
    if [ ! -z "$PUSH_TO_REGISTRY" ]; then
        local registry_image="$PUSH_TO_REGISTRY/$image_name"
        print_status "Building and pushing to registry: $registry_image"
        
        docker buildx build \
            --platform $PLATFORMS \
            --tag $registry_image \
            --push \
            .
        
        print_success "Multi-platform image built and pushed: $registry_image"
    else
        print_status "Building multi-platform image locally..."
        
        docker buildx build \
            --platform $PLATFORMS \
            --tag $image_name \
            --load \
            .
        
        print_success "Multi-platform image built locally: $image_name"
    fi
}

# Function to show image information
show_image_info() {
    echo ""
    print_status "Build Information:"
    echo "  Image: $IMAGE_NAME"
    echo "  Tag: $TAG"
    echo "  Platforms: $PLATFORMS"
    
    if [ ! -z "$PUSH_TO_REGISTRY" ]; then
        echo "  Registry: $PUSH_TO_REGISTRY"
        echo "  Registry Image: $PUSH_TO_REGISTRY/$IMAGE_NAME:$TAG"
        
        echo ""
        print_status "Pull commands:"
        echo "  docker pull $PUSH_TO_REGISTRY/$IMAGE_NAME:$TAG"
        
        echo ""
        print_status "Run commands:"
        echo "  docker run -d --name chat-api -p 3000:3000 $PUSH_TO_REGISTRY/$IMAGE_NAME:$TAG"
    fi
}

# Function to create platform-specific pull script
create_pull_script() {
    if [ ! -z "$PUSH_TO_REGISTRY" ]; then
        local pull_script="pull-chat-api-multi-platform.sh"
        
        cat > "$pull_script" << EOF
#!/bin/bash

# Pull Multi-Platform Chat API from Registry
# Generated by build-multi-platform.sh

set -e

echo "🐳 Pulling Multi-Platform Chat API from $PUSH_TO_REGISTRY..."

# Pull the multi-platform image
docker pull $PUSH_TO_REGISTRY/$IMAGE_NAME:$TAG

echo "✅ Multi-platform image pulled successfully!"
echo ""
echo "🚀 To run the container:"
echo "   docker run -d --name chat-api -p 3000:3000 $PUSH_TO_REGISTRY/$IMAGE_NAME:$TAG"
echo ""
echo "📖 API Documentation:"
echo "   http://localhost:3000/api-docs"
echo "   http://localhost:3000/health"
echo ""
echo "🔧 Platform Information:"
echo "   Built for: $PLATFORMS"
echo "   Compatible with: Intel/AMD 64-bit, ARM 64-bit, and ARM 32-bit systems"
EOF

        chmod +x "$pull_script"
        print_success "Created multi-platform pull script: $pull_script"
    fi
}

# Main execution
main() {
    print_status "Starting multi-platform Docker build..."
    
    # Parse command line arguments
    parse_args "$@"
    
    # Check prerequisites
    check_docker
    check_buildx
    
    # Setup buildx if available
    if [ "$BUILDX_AVAILABLE" = true ]; then
        setup_buildx
        
        # Build multi-platform
        build_multi_platform
    else
        print_warning "Docker Buildx not available. Building for first platform only: $(echo $PLATFORMS | cut -d',' -f1)"
        build_single_platform $(echo $PLATFORMS | cut -d',' -f1)
    fi
    
    # Show information
    show_image_info
    
    # Create pull script
    create_pull_script
    
    print_success "Multi-platform build completed successfully!"
}

# Run main function with all arguments
main "$@" 