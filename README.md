# Kaleb.Engineer Website

A professional software engineering portfolio and blog website built with Jekyll and served by a Swift Vapor backend. This project demonstrates full-stack development skills and follows industry best practices for production-ready applications.

## 🏗️ Architecture

The project uses a multi-component architecture:

- **`jekyll-site/`** - Static site generator using Jekyll for content management
- **`vapor-server/`** - Swift Vapor application serving the Jekyll-generated static files
- **`docker/`** - Containerization configuration for deployment
- **`scripts/`** - Build and deployment automation scripts

## 🚀 Quick Start

### Prerequisites

- **Ruby 3.2+** with Bundler for Jekyll
- **Swift 6.0+** for Vapor server
- **Docker & Docker Compose** for containerized deployment

### Local Development

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd kaleb-engineer
   ```

2. **Start development servers:**
   ```bash
   ./scripts/dev.sh
   ```
   
   This starts:
   - Jekyll development server at http://localhost:4000 (with live reload)
   - Vapor server at http://localhost:8080 (serving Jekyll content)

3. **Individual development servers:**
   ```bash
   # Jekyll only (for content development)
   ./scripts/dev.sh --jekyll-only
   
   # Vapor only (for backend development)  
   ./scripts/dev.sh --vapor-only
   ```

### Production Build

1. **Build all components:**
   ```bash
   ./scripts/build.sh
   ```

2. **Build with tests:**
   ```bash
   ./scripts/build.sh --test
   ```

3. **Clean build:**
   ```bash
   ./scripts/build.sh --clean
   ```

### Docker Deployment

1. **Deploy locally:**
   ```bash
   ./scripts/deploy.sh
   ```
   
   Application available at http://localhost:8080

2. **Check deployment status:**
   ```bash
   ./scripts/deploy.sh --status
   ```

3. **Stop deployment:**
   ```bash
   ./scripts/deploy.sh --stop
   ```

## 🛠️ Development Commands

### Jekyll Development
```bash
cd jekyll-site
bundle install
bundle exec jekyll serve --livereload
```

### Vapor Development
```bash
cd vapor-server
swift run VaporServer serve --hostname 0.0.0.0 --port 8080
```

### Docker Development
```bash
cd docker
docker-compose up --build
```

## 🧪 Testing

```bash
# Run Vapor server tests
cd vapor-server
swift test

# Build with tests
./scripts/build.sh --test
```

## 📁 Project Structure

```
kaleb-engineer/
├── jekyll-site/           # Jekyll static site
│   ├── _layouts/         # Page templates
│   ├── _includes/        # Reusable components
│   ├── _sass/           # SCSS stylesheets
│   ├── _posts/          # Blog posts
│   ├── assets/          # Static assets
│   ├── _config.yml      # Jekyll configuration
│   └── Gemfile          # Ruby dependencies
├── vapor-server/          # Swift Vapor backend
│   ├── Sources/         # Swift source code
│   ├── Tests/           # Unit tests
│   └── Package.swift    # Swift dependencies
├── docker/               # Docker configuration
│   ├── Dockerfile       # Multi-stage production build
│   ├── docker-compose.yml
│   └── Dockerfile.jekyll-dev
├── scripts/              # Automation scripts
│   ├── build.sh         # Build automation
│   ├── dev.sh           # Development environment
│   └── deploy.sh        # Deployment automation
└── README.md
```

## 🔧 Configuration

### Environment Variables

- `PORT` - Server port (default: 8080)
- `LOG_LEVEL` - Logging level (default: info)
- `ENVIRONMENT` - Runtime environment (development/production)

### Jekyll Configuration

Edit `jekyll-site/_config.yml` to customize:
- Site metadata (title, description, URL)
- Navigation menu
- Social links
- Build settings

### Vapor Configuration

The Vapor server is configured in `vapor-server/Sources/VaporServer/configure.swift` for:
- Static file serving from Jekyll build output
- CORS middleware
- Request logging (development only)
- Error handling

## 🚀 API Endpoints

- `GET /api/v1/health` - Health check endpoint
- `GET /api/v1/info` - Server information
- `GET /**` - Serves Jekyll-generated static content

## 🏅 Professional Standards

This project demonstrates production-ready code with:

- **Comprehensive documentation** for setup and development
- **Error handling** throughout with meaningful messages
- **Security best practices** with environment-based configuration
- **Performance optimization** with static site generation
- **Docker multi-stage builds** for efficient deployment
- **Automated testing** and build verification
- **Professional Git practices** with conventional commits

## 📝 License

This project is part of a professional portfolio. All rights reserved.

## 🤝 Contributing

This is a personal portfolio project, but feedback and suggestions are welcome via issues.

---

**Built with ❤️ using Swift, Jekyll, and Docker**