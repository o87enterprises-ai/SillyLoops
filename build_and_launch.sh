#!/bin/bash

# SampleBeat - Build and Launch Script
# Builds the Flutter web app and launches it in the browser

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🥁 SampleBeat - Build & Launch"
echo "=============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    echo ""
    echo "Please install Flutter:"
    echo "  macOS: brew install --cask flutter"
    echo "  Or visit: https://docs.flutter.dev/get-started/install"
    echo ""
    exit 1
fi

echo -e "${BLUE}📱 Checking Flutter installation...${NC}"
flutter --version
echo ""

# Run Flutter doctor
echo -e "${BLUE}🔍 Running Flutter Doctor...${NC}"
flutter doctor -v 2>&1 | head -20 || true
echo ""

# Download samples if needed
if [ ! -f "assets/samples/README.txt" ] && [ "$(ls -A assets/samples 2>/dev/null)" = "" ]; then
    echo -e "${YELLOW}📦 Downloading drum samples...${NC}"
    ./download_samples.sh || true
    echo ""
fi

# Get dependencies
echo -e "${BLUE}📥 Installing Flutter dependencies...${NC}"
flutter pub get
echo ""

# Clean previous build
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean
echo ""

# Build for web
echo -e "${BLUE}🔨 Building for web...${NC}"
flutter build web --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Web build successful!${NC}"
    echo ""
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Launch in browser
echo -e "${BLUE}🚀 Launching in browser...${NC}"

# Determine which browser to use
BROWSER=""
if command -v open &> /dev/null; then
    # macOS
    BROWSER="open"
elif command -v xdg-open &> /dev/null; then
    # Linux
    BROWSER="xdg-open"
elif command -v start &> /dev/null; then
    # Windows
    BROWSER="start"
fi

if [ -n "$BROWSER" ]; then
    BUILD_DIR="$SCRIPT_DIR/build/web"
    echo "Opening: $BUILD_DIR/index.html"
    
    # Start a local server (Python)
    echo -e "${GREEN}🌐 Starting local server...${NC}"
    echo ""
    echo -e "${YELLOW}Note: Press Ctrl+C to stop the server${NC}"
    echo ""
    
    cd "$BUILD_DIR"
    
    # Try Python 3 first, then Python 2
    if command -v python3 &> /dev/null; then
        python3 -m http.server 8080 &
        SERVER_PID=$!
        sleep 2
        $BROWSER "http://localhost:8080"
        wait $SERVER_PID
    elif command -v python &> /dev/null; then
        python -m SimpleHTTPServer 8080 &
        SERVER_PID=$!
        sleep 2
        $BROWSER "http://localhost:8080"
        wait $SERVER_PID
    else
        echo -e "${RED}❌ No Python found. Please open build/web/index.html manually${NC}"
        echo "Path: $BUILD_DIR/index.html"
        $BROWSER "$BUILD_DIR/index.html"
    fi
else
    echo -e "${YELLOW}⚠️  Could not determine browser${NC}"
    echo "Please open manually: $SCRIPT_DIR/build/web/index.html"
fi

echo ""
echo "=============================="
echo -e "${GREEN}✅ SampleBeat is ready!${NC}"
