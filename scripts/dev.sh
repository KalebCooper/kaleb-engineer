#!/bin/bash

# Development script for Kaleb.Engineer website
# Starts Jekyll and Vapor in development mode

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

# Cleanup function to kill background processes
cleanup() {
    log_info "Shutting down development servers..."
    
    if [ ! -z "${JEKYLL_PID:-}" ]; then
        kill $JEKYLL_PID 2>/dev/null || true
        log_info "Jekyll server stopped"
    fi
    
    if [ ! -z "${VAPOR_PID:-}" ]; then
        kill $VAPOR_PID 2>/dev/null || true
        log_info "Vapor server stopped"
    fi
    
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Check if required tools are installed
check_dependencies() {
    log_info "Checking development dependencies..."
    
    local missing_deps=()
    
    if ! command -v bundle &> /dev/null; then
        missing_deps+=("bundler (Ruby)")
    fi
    
    if ! command -v swift &> /dev/null; then
        missing_deps+=("swift")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install the missing dependencies and try again."
        exit 1
    fi
    
    log_success "All development dependencies are installed"
}

# Setup Jekyll development environment
setup_jekyll() {
    log_info "Setting up Jekyll development environment..."
    
    cd "$PROJECT_ROOT/jekyll-site"
    
    # Check if Jekyll is available and functional
    if command -v bundle &> /dev/null && bundle exec jekyll --version &> /dev/null; then
        log_info "Jekyll is available - setting up environment..."
        
        # Install gems if needed
        if [ ! -f "Gemfile.lock" ] || [ "Gemfile" -nt "Gemfile.lock" ]; then
            log_info "Installing/updating Jekyll gems..."
            if ! bundle install; then
                log_warning "Bundle install failed - Jekyll development server will not be available"
                cd "$PROJECT_ROOT"
                return 1
            fi
        fi
        
        log_success "Jekyll environment ready"
    else
        log_warning "Jekyll not available or not functional"
        log_info "Use Docker development environment for full Jekyll functionality"
        cd "$PROJECT_ROOT"
        return 1
    fi
    
    cd "$PROJECT_ROOT"
    return 0
}

# Start Jekyll development server
start_jekyll() {
    log_info "Starting Jekyll development server on http://localhost:4000..."
    
    cd "$PROJECT_ROOT/jekyll-site"
    JEKYLL_ENV=development bundle exec jekyll serve --livereload --port 4000 --host 0.0.0.0 &
    JEKYLL_PID=$!
    cd "$PROJECT_ROOT"
    
    # Give Jekyll a moment to start
    sleep 3
    
    if kill -0 $JEKYLL_PID 2>/dev/null; then
        log_success "Jekyll server started (PID: $JEKYLL_PID)"
    else
        log_error "Failed to start Jekyll server"
        exit 1
    fi
}

# Start Vapor development server
start_vapor() {
    log_info "Starting Vapor development server on http://localhost:8080..."
    
    cd "$PROJECT_ROOT/vapor-server"
    swift run VaporServer serve --hostname 0.0.0.0 --port 8080 --env development &
    VAPOR_PID=$!
    cd "$PROJECT_ROOT"
    
    # Give Vapor a moment to start
    sleep 5
    
    if kill -0 $VAPOR_PID 2>/dev/null; then
        log_success "Vapor server started (PID: $VAPOR_PID)"
    else
        log_error "Failed to start Vapor server"
        exit 1
    fi
}

# Monitor process health
monitor_servers() {
    log_info "Monitoring servers... (Press Ctrl+C to stop)"
    
    while true; do
        # Check if Jekyll is still running
        if [ ! -z "${JEKYLL_PID:-}" ] && ! kill -0 $JEKYLL_PID 2>/dev/null; then
            log_warning "Jekyll server stopped unexpectedly"
            start_jekyll
        fi
        
        # Check if Vapor is still running
        if [ ! -z "${VAPOR_PID:-}" ] && ! kill -0 $VAPOR_PID 2>/dev/null; then
            log_warning "Vapor server stopped unexpectedly"
            start_vapor
        fi
        
        sleep 10
    done
}

# Main development function
main() {
    local mode="both"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --jekyll-only)
                mode="jekyll"
                shift
                ;;
            --vapor-only)
                mode="vapor"
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Start development servers for Kaleb.Engineer"
                echo ""
                echo "Options:"
                echo "  --jekyll-only   Start only Jekyll development server"
                echo "  --vapor-only    Start only Vapor development server"
                echo "  -h, --help      Show this help message"
                echo ""
                echo "Default: Starts both Jekyll (port 4000) and Vapor (port 8080) servers"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                log_error "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    log_info "Starting Kaleb.Engineer development environment..."
    
    check_dependencies
    
    case $mode in
        "jekyll")
            if setup_jekyll; then
                start_jekyll
                log_success "Jekyll development server running at http://localhost:4000"
                log_info "Press Ctrl+C to stop"
                wait $JEKYLL_PID
            else
                log_error "Jekyll setup failed. Use Docker development environment or fix Ruby setup."
                exit 1
            fi
            ;;
        "vapor")
            start_vapor
            log_success "Vapor development server running at http://localhost:8080"
            log_info "Press Ctrl+C to stop"
            wait $VAPOR_PID
            ;;
        "both")
            local jekyll_available=false
            if setup_jekyll; then
                start_jekyll
                jekyll_available=true
            else
                log_warning "Jekyll unavailable - continuing with Vapor only"
            fi
            
            start_vapor
            
            if [ "$jekyll_available" = true ]; then
                log_success "Development environment ready!"
                log_info "Jekyll (with live reload): http://localhost:4000"
                log_info "Vapor API server: http://localhost:8080"
                log_info "Vapor serving Jekyll: http://localhost:8080"
                
                monitor_servers
            else
                log_success "Vapor development server ready!"
                log_info "Vapor API server: http://localhost:8080"
                log_warning "Jekyll unavailable - use Docker for full development environment"
                log_info "Press Ctrl+C to stop"
                wait $VAPOR_PID
            fi
            ;;
    esac
}

# Execute main function with all arguments
main "$@"