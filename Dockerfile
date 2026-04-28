# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

USER root
WORKDIR /app

# Disable analytics
RUN flutter config --no-analytics

# Copy configuration files
COPY pubspec.yaml ./
COPY analysis_options.yaml ./

# Install dependencies
RUN flutter pub get

# Copy source and assets
COPY lib/ ./lib/
COPY web/ ./web/
COPY assets/ ./assets/

# Download samples during build with better verbosity and error handling
RUN mkdir -p assets/samples && \
    echo "Downloading samples..." && \
    curl -L -v -o assets/samples/hiphop_drums.zip "https://99sounds.org/wp-content/uploads/2021/03/99Sounds-Hip-Hop-Drums.zip" && \
    echo "Checking zip file..." && \
    ls -lh assets/samples/hiphop_drums.zip && \
    echo "Extracting samples..." && \
    unzip -o assets/samples/hiphop_drums.zip -d assets/samples/ && \
    echo "Cleaning up..." && \
    rm assets/samples/hiphop_drums.zip || (echo "Sample step failed but continuing to build..." && ls -R assets/samples)

# Build the web app
RUN echo "Starting Flutter web build..." && \
    flutter build web --release --base-href=/ && \
    echo "Build completed successfully!"

# Stage 2: Serve using unprivileged Nginx
FROM nginxinc/nginx-unprivileged:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build output
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 7860

CMD ["nginx", "-g", "daemon off;"]
