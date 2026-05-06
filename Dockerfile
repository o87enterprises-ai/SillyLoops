# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

USER root
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Disable analytics
RUN flutter config --no-analytics

# Environment check
RUN flutter doctor -v

# Copy configuration files
COPY pubspec.yaml ./
COPY analysis_options.yaml ./

# Install dependencies
RUN flutter pub get

# Copy source and assets
COPY lib/ ./lib/
COPY web/ ./web/
COPY assets/ ./assets/

# Build the web app with explicit error capture
RUN echo "Starting Flutter web build..." && \
    flutter build web --release --base-href=/ --verbose > build_log.txt 2>&1 || \
    (echo "BUILD FAILED! LOG FOLLOWS:" && cat build_log.txt && exit 1) && \
    echo "Build completed successfully!"

# Stage 2: Serve using unprivileged Nginx
FROM nginxinc/nginx-unprivileged:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build output
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
