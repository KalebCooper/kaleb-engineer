#!/bin/bash

# Deployment script for Kaleb.Engineer website
# Builds and deploys the Docker container

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    log_info "Checking deployment dependencies..."
    
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install the missing dependencies and try again."
        exit 1
    fi
    
    log_success "All deployment dependencies are installed"
}

# Build Docker image
build_image() {
    local tag="$1"
    
    log_info "Building Docker image: $tag"
    
    cd "$PROJECT_ROOT"
    docker build -f docker/Dockerfile -t "$tag" .
    
    if [ $? -eq 0 ]; then
        log_success "Docker image built successfully: $tag"
    else
        log_error "Failed to build Docker image"
        exit 1
    fi
}

# Run health check
health_check() {
    local port="$1"
    local max_attempts=30
    local attempt=1
    
    log_info "Performing health check on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "http://localhost:$port/api/v1/health" > /dev/null 2>&1; then
            log_success "Health check passed"
            return 0
        fi
        
        log_info "Health check attempt $attempt/$max_attempts failed, retrying in 2 seconds..."
        sleep 2
        ((attempt++))
    done
    
    log_error "Health check failed after $max_attempts attempts"
    return 1
}

# Deploy locally using Docker Compose
deploy_local() {
    log_info "Deploying locally using Docker Compose..."
    
    cd "$PROJECT_ROOT/docker"
    
    # Stop existing containers
    docker-compose down 2>/dev/null || true
    
    # Build and start containers
    docker-compose up --build -d
    
    if [ $? -eq 0 ]; then
        log_success "Application deployed locally"
        
        # Wait a moment for the container to fully start
        sleep 5
        
        # Perform health check
        if health_check 8080; then
            log_success "Local deployment successful!"
            log_info "Application available at: http://localhost:8080"
            log_info "API health check: http://localhost:8080/api/v1/health"
            log_info "API info: http://localhost:8080/api/v1/info"
        else
            log_error "Health check failed - deployment may have issues"
            exit 1
        fi
    else
        log_error "Failed to deploy locally"
        exit 1
    fi
}

# Production deployment (placeholder for future implementation)
deploy_production() {
    log_warning "Production deployment is not yet implemented"
    log_info "This would typically involve:"
    log_info "  - Building and tagging image for production registry"
    log_info "  - Pushing to container registry"
    log_info "  - Updating production infrastructure"
    log_info "  - Running health checks"
    log_info "  - Notifying monitoring systems"
}

# Show deployment status
show_status() {
    log_info "Deployment Status:"
    
    cd "$PROJECT_ROOT/docker"
    
    # Show running containers
    echo ""
    docker-compose ps
    
    # Show container logs (last 20 lines)
    echo ""
    log_info "Recent logs:"
    docker-compose logs --tail=20
}

# Stop deployment
stop_deployment() {
    log_info "Stopping deployment..."
    
    cd "$PROJECT_ROOT/docker"
    docker-compose down
    
    log_success "Deployment stopped"
}

# Main deployment function
main() {
    local action="local"
    local tag="kaleb-engineer:latest"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --production)
                action="production"
                shift
                ;;
            --tag)
                tag="$2"
                shift 2
                ;;
            --status)
                action="status"
                shift
                ;;
            --stop)
                action="stop"
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Deploy the Kaleb.Engineer application"
                echo ""
                echo "Options:"
                echo "  --production    Deploy to production (not implemented yet)"
                echo "  --tag TAG       Docker image tag (default: kaleb-engineer:latest)"
                echo "  --status        Show deployment status"
                echo "  --stop          Stop running deployment"
                echo "  -h, --help      Show this help message"
                echo ""
                echo "Default: Deploy locally using Docker Compose"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                log_error "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    case $action in
        "local")
            log_info "Starting local deployment..."
            check_dependencies
            deploy_local
            ;;
        "production")
            deploy_production
            ;;
        "status")
            show_status
            ;;
        "stop")
            stop_deployment
            ;;
        *)
            log_error "Unknown action: $action"
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"