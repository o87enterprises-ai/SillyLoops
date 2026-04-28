# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

USER root

WORKDIR /app
COPY . .

# Build the web app with explicit base-href
RUN flutter pub get
RUN flutter build web --release --base-href=/

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/

# Copy the build output
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 7860
EXPOSE 7860

CMD ["nginx", "-g", "daemon off;"]
