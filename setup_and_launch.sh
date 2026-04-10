#!/bin/bash

# SampleBeat - Full Setup and Launch Script
# This script installs dependencies, downloads samples, builds, and launches the app

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🥁 SampleBeat - Complete Setup & Launch"
echo "======================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Function to print colored messages
print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check operating system
OS="$(uname -s)"
echo "Detected OS: $OS"
echo ""

# Step 1: Check/install Flutter
print_step "Checking Flutter installation..."

if command -v flutter &> /dev/null; then
    print_success "Flutter is installed"
    flutter --version
else
    print_error "Flutter is not installed"
    echo ""
    print_info "Installing Flutter..."
    
    if [[ "$OS" == "Darwin" ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            print_info "Homebrew found, installing Flutter..."
            brew install --cask flutter
            print_success "Flutter installed via Homebrew"
        else
            print_error "Homebrew not found. Please install Flutter manually:"
            echo "  1. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo "  2. Then run: brew install --cask flutter"
            exit 1
        fi
    elif [[ "$OS" == "Linux" ]]; then
        print_error "Please install Flutter manually for Linux:"
        echo "  Visit: https://docs.flutter.dev/get-started/install/linux"
        exit 1
    else
        print_error "Unsupported OS. Please install Flutter manually:"
        echo "  Visit: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    
    # Add Flutter to PATH
    export PATH="$PATH:$HOME/snap/flutter/common/flutter/bin"
    export PATH="$PATH:/opt/homebrew/bin"
    export PATH="$PATH:/usr/local/bin"
fi

echo ""

# Step 2: Run Flutter doctor
print_step "Running Flutter Doctor..."
flutter doctor -v 2>&1 | head -15 || true
echo ""

# Step 3: Enable web support
print_step "Enabling Flutter web support..."
flutter config --enable-web 2>/dev/null || true
print_success "Web support enabled"
echo ""

# Step 4: Install project dependencies
print_step "Installing project dependencies..."
flutter pub get
print_success "Dependencies installed"
echo ""

# Step 5: Download drum samples
print_step "Setting up drum samples..."
if [ -f "./download_samples.sh" ]; then
    ./download_samples.sh || true
else
    mkdir -p assets/samples
    echo "Sample directory created at: assets/samples/"
fi
print_success "Samples ready"
echo ""

# Step 6: Build for web
print_step "Building for web (release mode)..."
flutter build web --release

if [ $? -eq 0 ]; then
    print_success "Web build completed!"
else
    print_error "Build failed"
    exit 1
fi
echo ""

# Step 7: Launch in browser
print_step "Launching SampleBeat in your browser..."
echo ""

BUILD_DIR="$SCRIPT_DIR/build/web"

# Create a simple HTTP server using Python
start_server() {
    cd "$BUILD_DIR"
    
    if command -v python3 &> /dev/null; then
        echo "Starting Python 3 HTTP server on port 8080..."
        python3 -m http.server 8080
    elif command -v python &> /dev/null; then
        echo "Starting Python HTTP server on port 8080..."
        python -m SimpleHTTPServer 8080
    else
        echo "Error: Python not found. Cannot start server."
        exit 1
    fi
}

# Open browser
open_browser() {
    sleep 2  # Wait for server to start
    
    if [[ "$OS" == "Darwin" ]]; then
        open "http://localhost:8080"
    elif [[ "$OS" == "Linux" ]]; then
        xdg-open "http://localhost:8080" 2>/dev/null || sensible-browser "http://localhost:8080" 2>/dev/null || true
    fi
}

echo "======================================="
echo -e "${GREEN}🎉 SampleBeat is ready!${NC}"
echo ""
echo "The app will be available at: http://localhost:8080"
echo ""
echo -e "${YELLOW}Controls:${NC}"
echo "  • Tap pads to play sounds"
echo "  • Long-press pads to import samples"
echo "  • Use Bank buttons (A-D) to switch banks"
echo "  • Adjust BPM with +/- buttons"
echo ""
echo -e "${YELLOW}Note:${NC} Press Ctrl+C to stop the server"
echo "======================================="
echo ""

# Start server in background and open browser
start_server &
SERVER_PID=$!
open_browser &

# Wait for server process
wait $SERVER_PID
