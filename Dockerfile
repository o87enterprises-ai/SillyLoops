# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

USER root

WORKDIR /app
COPY . .

# Build the web app
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve the app using Python
FROM python:3.9-slim

# Copy the build output
WORKDIR /app
COPY --from=build-env /app/build/web .

# Expose port 7860
EXPOSE 7860

# Start a simple HTTP server
CMD ["python3", "-m", "http.server", "7860"]
