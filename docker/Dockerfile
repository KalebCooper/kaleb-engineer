# Multi-stage Dockerfile for Kaleb.Engineer website
# Builds Jekyll site and Vapor server in a single container

# ================================
# Jekyll Build Stage
# ================================
FROM ruby:3.2-alpine AS jekyll-build

# Install build dependencies for Jekyll
RUN apk add --no-cache \
    build-base \
    gcompat

WORKDIR /jekyll

# Copy Jekyll site files
COPY jekyll-site/Gemfile* ./
RUN bundle install

# Copy remaining Jekyll files and build site
COPY jekyll-site/ ./
RUN bundle exec jekyll build --destination _site

# ================================
# Swift Build Stage
# ================================
FROM swift:6.1-noble AS vapor-build

# Install OS updates and dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev

# Set up build area
WORKDIR /build

# Copy Vapor server files for dependency resolution
COPY vapor-server/Package.* ./
RUN swift package resolve \
    $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire Vapor server source
COPY vapor-server/ ./

# Create staging area
RUN mkdir /staging

# Build the Vapor application
RUN --mount=type=cache,target=/build/.build \
    swift build -c release \
        --product VaporServer \
        --static-swift-stdlib \
        -Xlinker -ljemalloc && \
    # Copy executable to staging
    cp "$(swift build -c release --show-bin-path)/VaporServer" /staging && \
    # Copy resources
    find -L "$(swift build -c release --show-bin-path)" -regex '.*\.resources$' -exec cp -Ra {} /staging \;

# Switch to staging
WORKDIR /staging

# Copy Swift backtrace binary
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# ================================
# Production Runtime Stage
# ================================
FROM ubuntu:noble

# Install runtime dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
        libjemalloc2 \
        ca-certificates \
        tzdata \
    && rm -r /var/lib/apt/lists/*

# Create application user
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Set working directory
WORKDIR /app

# Copy built Jekyll site from Jekyll build stage
COPY --from=jekyll-build --chown=vapor:vapor /jekyll/_site ./jekyll-site/_site

# Copy built Vapor application from Swift build stage
COPY --from=vapor-build --chown=vapor:vapor /staging ./

# Configure Swift backtrace
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

# Switch to vapor user
USER vapor:vapor

# Expose port
EXPOSE 8080

# Set entry point
ENTRYPOINT ["./VaporServer"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]