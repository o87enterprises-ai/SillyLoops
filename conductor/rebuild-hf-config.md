# Plan: Rebuild Configuration for Hugging Face Spaces

This plan addresses the "configuration loop" issue on Hugging Face Spaces by standardizing the Docker and Nginx configurations to strictly follow HF requirements.

## Objective
Resolve the configuration loop and ensure the "SillyLoops" application builds and runs successfully as a Docker SDK Space on Hugging Face.

## Key Files & Context
- `README.md`: Contains HF metadata (YAML frontmatter).
- `Dockerfile`: Defines the build and runtime environment.
- `nginx.conf`: Configures the web server for the Space.

## Implementation Steps

### 1. Standardize Hugging Face Metadata
- **File:** `README.md`
- **Change:** Update the YAML frontmatter to include `app_port: 7860` and ensure it is the only content before the title.

```yaml
---
title: SillyLoops
emoji: 🎹
colorFrom: purple
colorTo: pink
sdk: docker
app_port: 7860
pinned: false
---
```

### 2. Optimize Nginx Configuration
- **File:** `nginx.conf`
- **Change:** Remove `server_name localhost`, simplify the server block, and add `Cross-Origin-Embedder-Policy` and `Cross-Origin-Opener-Policy` headers.

```nginx
server {
    listen 7860;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;

        # Standard Security and Proxy Headers
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Content-Type-Options "nosniff";
        
        # Required for many modern web APIs (SharedArrayBuffer, etc) used by Flutter
        add_header Cross-Origin-Embedder-Policy "require-corp";
        add_header Cross-Origin-Opener-Policy "same-origin";
    }

    # Optimization for static assets
    location ~* \.(?:js|css|json|wasm|wav|mp3)$ {
        root /usr/share/nginx/html;
        expires 1y;
        add_header Cache-Control "public";
        access_log off;
    }
}
```

### 3. Rebuild Dockerfile
- **File:** `Dockerfile`
- **Change:** Use `nginxinc/nginx-unprivileged:alpine` for the runtime stage. Ensure assets (samples) are downloaded during the build.

```dockerfile
# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

USER root
WORKDIR /app

# Copy configuration files
COPY pubspec.yaml ./
COPY analysis_options.yaml ./

# Install dependencies
RUN flutter pub get

# Copy source and assets
COPY lib/ ./lib/
COPY web/ ./web/
COPY assets/ ./assets/

# Download samples during build to ensure they are present in the image
# (Using the script logic directly or calling the script)
RUN mkdir -p assets/samples && \
    curl -L -o assets/samples/hiphop_drums.zip "https://99sounds.org/wp-content/uploads/2021/03/99Sounds-Hip-Hop-Drums.zip" && \
    unzip -o assets/samples/hiphop_drums.zip -d assets/samples/ && \
    rm assets/samples/hiphop_drums.zip || echo "Sample download failed, proceeding with empty samples"

# Build the web app
RUN flutter build web --release \
    --web-renderer html \
    --base-href=/

# Stage 2: Serve using unprivileged Nginx
FROM nginxinc/nginx-unprivileged:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build output
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXpose 7860

CMD ["nginx", "-g", "daemon off;"]
```


### 4. Verification
- Verify that port 7860 is used throughout.
- Ensure the `base-href` matches HF's proxy expectations.

## Verification & Testing
- The primary verification will be the successful deployment and "Running" state on Hugging Face Spaces.
- Local verification using `docker build -t sillyloops . && docker run -p 7860:7860 sillyloops`.
