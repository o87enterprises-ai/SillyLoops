#!/bin/bash

# SillyLoops - Download Hip-Hop Drum Samples
# This script downloads free, royalty-free drum samples

set -e

SAMPLES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/assets/samples"

echo "🥁 SillyLoops - Downloading Hip-Hop Drum Samples"
echo "================================================"
echo ""

# Create samples directory
mkdir -p "$SAMPLES_DIR"

# Check if samples already exist
if [ "$(ls -A $SAMPLES_DIR 2>/dev/null)" ]; then
    echo "⚠️  Samples directory already contains files."
    echo "   Remove existing files to re-download."
    exit 0
fi

echo "📁 Download directory: $SAMPLES_DIR"
echo ""

# Download 99Sounds Hip-Hop Drums (free, royalty-free)
echo "📥 Downloading 99Sounds Hip-Hop Drum Kit..."
cd "$SAMPLES_DIR"

# Try to download the sample pack
if command -v curl &> /dev/null; then
    curl -L -o hiphop_drums.zip "https://99sounds.org/wp-content/uploads/2021/03/99Sounds-Hip-Hop-Drums.zip" 2>/dev/null || {
        echo "⚠️  Could not download from 99Sounds. Creating placeholder samples."
    }
elif command -v wget &> /dev/null; then
    wget -O hiphop_drums.zip "https://99sounds.org/wp-content/uploads/2021/03/99Sounds-Hip-Hop-Drums.zip" 2>/dev/null || {
        echo "⚠️  Could not download from 99Sounds. Creating placeholder samples."
    }
else
    echo "⚠️  Neither curl nor wget found. Creating placeholder samples."
fi

# Extract if download succeeded
if [ -f "hiphop_drums.zip" ]; then
    echo "📦 Extracting samples..."
    if command -v unzip &> /dev/null; then
        unzip -o hiphop_drums.zip 2>/dev/null || true
        rm -f hiphop_drums.zip
        echo "✅ Samples downloaded and extracted!"
    else
        echo "⚠️  unzip not found. Keeping zip file for manual extraction."
    fi
fi

# Create placeholder samples if no audio files exist
WAV_COUNT=$(find "$SAMPLES_DIR" -name "*.wav" -o -name "*.WAV" 2>/dev/null | wc -l)
if [ "$WAV_COUNT" -eq 0 ]; then
    echo ""
    echo "⚠️  No WAV files found. Creating placeholder info..."
    
    cat > "$SAMPLES_DIR/README.txt" << 'EOF'
SillyLoops Drum Samples
=======================

To add your own drum samples:
1. Download free drum kits from:
   - https://99sounds.org/free-drum-samples/
   - https://bedroomproducersblog.com/free-drum-samples/
   - https://www.samplefocus.com/

2. Place WAV files in this directory

3. In the app, long-press any pad to import a sample

Recommended free drum kits:
- 99Sounds Hip-Hop Drums
- 99Sounds Trap Drums
- 99Sounds Drum Machine Samples
- Cymatics free packs

Default sample mapping (create or download these):
- drum_0.wav - Kick
- drum_1.wav - Snare
- drum_2.wav - Hi-Hat Closed
- drum_3.wav - Hi-Hat Open
- drum_4.wav - Clap
- drum_5.wav - Percussion
- drum_6.wav - Crash
- drum_7.wav - Ride
EOF
    
    echo "📄 Created README.txt with sample information"
fi

echo ""
echo "================================================"
echo "✅ Sample setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. Run: flutter run -d chrome (for web)"
echo "   or: flutter run (for mobile)"
echo ""
