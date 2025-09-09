# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based website (www.kaleb.engineer) served through a Swift Vapor application, heavily inspired by Swift.org's design and structure. The project serves as both a professional landing page/blog and a showcase of full-stack development skills.

## Architecture

The project follows a multi-component architecture:

- **`jekyll-site/`**: Static site generator using Jekyll, contains all website content, layouts, and styling
- **`vapor-server/`**: Swift Vapor application that serves the Jekyll-generated static files  
- **`docker/`**: Containerization configuration for deployment
- **`scripts/`**: Build and deployment automation scripts

The Jekyll site generates static HTML/CSS/JS which the Vapor server serves, combining the benefits of static site performance with Swift server capabilities for future API endpoints.

## Development Commands

### Quick Start
```bash
# Start both Jekyll and Vapor development servers
./scripts/dev.sh

# Build all components
./scripts/build.sh

# Deploy locally with Docker
./scripts/deploy.sh
```

### Individual Development Servers
```bash
# Jekyll development (port 4000) with live reload
./scripts/dev.sh --jekyll-only

# Vapor development (port 8080) 
./scripts/dev.sh --vapor-only
```

### Manual Jekyll Development
```bash
cd jekyll-site
bundle install
bundle exec jekyll serve --livereload
```

### Manual Vapor Development  
```bash
cd vapor-server
swift run VaporServer serve --hostname 0.0.0.0 --port 8080
```

### Docker Development
```bash
cd docker
docker-compose up --build
```

### Code Quality
```bash
# Build with tests
./scripts/build.sh --test

# Swift tests only
cd vapor-server && swift test

# Jekyll build verification
cd jekyll-site && bundle exec jekyll build
```

## Professional Standards

This is a **public repository** designed as a professional portfolio piece. All code must meet production-ready standards:

- Swift code follows official Swift style guidelines with SwiftLint enforcement
- Comprehensive inline documentation for complex logic
- Unit tests with 70% minimum coverage target
- Error handling with meaningful error messages throughout
- Security best practices with environment-based secrets management

## Key Implementation Notes

- The project structure mirrors Swift.org's architecture patterns
- Jekyll site will be built and served by the Vapor application (not served independently)
- Docker multi-stage builds optimize for both development and production
- CI/CD pipeline includes automated testing, security scanning, and deployment
- All secrets and sensitive configuration must use environment variables (never committed)

## Development Session Guidelines

**IMPORTANT: Always clean up background processes when development sessions end**

### Server Cleanup Protocol
```bash
# Always run at end of sessions to clean up background servers
pkill -f VaporServer
pkill -f jekyll
```

### Ruby/Jekyll Environment Notes
- System Ruby may have protobuf conflicts with Jekyll dependencies
- Build script includes fallback for Ruby dependency issues
- Docker environment resolves all Ruby/Jekyll compatibility problems
- For local Jekyll development, consider using Docker or rbenv/rvm

### Testing and Validation
- Always test build scripts end-to-end before considering tasks complete
- Verify both Jekyll site generation and Vapor server compilation
- Check that API endpoints respond correctly
- Validate static file serving works properly

## Current State

**Milestone 1 Complete ✅** - Foundation setup completed:
- Jekyll site structure with layouts, styling, and configuration
- Vapor server with static file serving and API endpoints  
- Docker multi-stage build configuration
- Development and deployment automation scripts
- Comprehensive documentation

Ready for content development and feature implementation.