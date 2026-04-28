# Stage 1: Build the Flutter web app
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor -v

# Copy project files
WORKDIR /app
COPY . .

# Build the web app
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Copy the build output to Nginx's html directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 7860 (Hugging Face default)
EXPOSE 7860

# Update Nginx config to listen on port 7860
RUN sed -i 's/listen\( \)*80;/listen 7860;/' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
