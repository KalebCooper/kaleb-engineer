#!/bin/bash

# Build script for Kaleb.Engineer website
# Builds both Jekyll site and Vapor server components

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
    log_info "Checking dependencies..."
    
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
    
    log_success "All dependencies are installed"
}

# Build Jekyll site
build_jekyll() {
    log_info "Building Jekyll site..."
    
    cd "$PROJECT_ROOT/jekyll-site"
    
    # Check if Jekyll is available and functional
    if command -v bundle &> /dev/null && bundle exec jekyll --version &> /dev/null; then
        log_info "Jekyll is available - building with Jekyll..."
        
        # Install gems if needed
        if [ ! -f "Gemfile.lock" ] || [ "Gemfile" -nt "Gemfile.lock" ]; then
            log_info "Installing/updating gems..."
            if ! bundle install; then
                log_warning "Bundle install failed - falling back to static build"
                build_jekyll_fallback
                return
            fi
        fi
        
        # Build the site
        if JEKYLL_ENV=production bundle exec jekyll build; then
            log_success "Jekyll site built successfully with Jekyll"
        else
            log_warning "Jekyll build failed - falling back to static build"
            build_jekyll_fallback
        fi
    else
        log_warning "Jekyll not available or not functional - using static build"
        build_jekyll_fallback
    fi
    
    # Verify build output exists
    if [ ! -d "_site" ] || [ -z "$(ls -A _site)" ]; then
        log_error "Jekyll build failed - _site directory is missing or empty"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
}

# Fallback Jekyll build using existing static files
build_jekyll_fallback() {
    log_info "Using existing static files as fallback..."
    
    # Ensure _site directory exists
    mkdir -p "_site"
    
    # If we have a static index.html, ensure it exists
    if [ -f "_site/index.html" ]; then
        log_success "Static Jekyll site ready (using existing files)"
    else
        log_error "No Jekyll build output available - please run Docker build or fix Ruby environment"
        exit 1
    fi
}

# Build Vapor server
build_vapor() {
    log_info "Building Vapor server..."
    
    cd "$PROJECT_ROOT/vapor-server"
    
    # Resolve dependencies
    swift package resolve
    
    # Build in release mode
    swift build -c release
    
    # Verify build output exists
    if [ ! -f ".build/release/VaporServer" ]; then
        log_error "Vapor build failed - executable not found"
        exit 1
    fi
    
    log_success "Vapor server built successfully"
    cd "$PROJECT_ROOT"
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    cd "$PROJECT_ROOT/vapor-server"
    
    # Run Swift tests
    swift test
    
    log_success "All tests passed"
    cd "$PROJECT_ROOT"
}

# Main build function
main() {
    log_info "Starting build process for Kaleb.Engineer..."
    
    # Parse command line arguments
    local run_tests=false
    local clean_build=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --test)
                run_tests=true
                shift
                ;;
            --clean)
                clean_build=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --test    Run tests after building"
                echo "  --clean   Clean build directories before building"
                echo "  -h, --help Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                log_error "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Clean build directories if requested
    if [ "$clean_build" = true ]; then
        log_info "Cleaning build directories..."
        rm -rf "$PROJECT_ROOT/jekyll-site/_site"
        rm -rf "$PROJECT_ROOT/vapor-server/.build"
        log_success "Build directories cleaned"
    fi
    
    check_dependencies
    build_jekyll
    build_vapor
    
    if [ "$run_tests" = true ]; then
        run_tests
    fi
    
    log_success "Build completed successfully!"
    log_info "Jekyll site: $PROJECT_ROOT/jekyll-site/_site"
    log_info "Vapor server: $PROJECT_ROOT/vapor-server/.build/release/VaporServer"
}

# Execute main function with all arguments
main "$@"