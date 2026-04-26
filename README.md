# SillyLoops - Retro ARP Sampler 🎹

A Flutter-based retro arpeggiator sampler with hip-hop drum machine capabilities.

![SillyLoops](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **8 Velocity-Sensitive Pads** - Trigger samples with visual feedback
- **4 Bank System** - Store up to 32 different samples (4 banks × 8 pads)
- **Loop Mode** - Toggle one-shot or loop playback per sample
- **BPM Control** - Adjustable tempo from 60-200 BPM
- **🎤 Microphone Recording** - Record audio directly from your mic
- **📶 Bluetooth MIDI** - Connect external MIDI controllers
- **Sample Import** - Load your own WAV/MP3 files
- **Low-Latency Audio** - JUCE audio engine for professional performance
- **Retro LCD Display** - Visual feedback for current settings

## Quick Start

### Prerequisites

- **Flutter SDK** 3.0+ ([Install Guide](https://docs.flutter.dev/get-started/install))
- **Xcode** (for iOS builds)
- **Android Studio** (for Android builds)
- **CMake** (for JUCE native build)

### Installation

1. **Clone the repository:**
```bash
cd /Volumes/Duck_Drive/software-dev/o87Dev/builds/sillyloops
```

2. **Download drum samples:**
```bash
./download_samples.sh
```

3. **Install Flutter dependencies:**
```bash
flutter pub get
```

4. **Run the app:**

**Web:**
```bash
flutter run -d chrome
```

**iOS Simulator:**
```bash
flutter run -d ios
```

**Android Emulator:**
```bash
flutter run -d android
```

**Physical Device:**
```bash
flutter run
```

## Project Structure

```
sillyloops/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── providers/
│   │   ├── sample_provider.dart  # Sample management state
│   │   └── audio_provider.dart   # Audio playback state (recording, MIDI)
│   ├── screens/
│   │   └── home_screen.dart      # Main UI screen
│   ├── widgets/
│   │   ├── drum_pad.dart         # Individual pad component
│   │   ├── pad_grid.dart         # 8-pad grid layout
│   │   ├── bank_selector.dart    # Bank switching UI
│   │   ├── control_panel.dart    # BPM, transport controls
│   │   ├── lcd_display.dart      # Retro LCD display
│   │   ├── recording_panel.dart  # Recording UI with level meter
│   │   └── bluetooth_panel.dart  # Bluetooth MIDI connection UI
│   └── services/
│       └── audio_engine_channel.dart  # Platform channels
├── web/
│   ├── standalone.html           # Standalone web version (no Flutter)
│   ├── index.html                # Flutter web entry
│   └── manifest.json             # PWA config
├── native_audio/                 # JUCE audio engine
│   ├── CMakeLists.txt
│   ├── AudioEngine.h/cpp
│   ├── SamplerVoice.h/cpp
│   ├── SamplePlayer.h/cpp
│   └── Main.cpp
├── assets/
│   └── samples/                  # Drum samples
├── android/                      # Android platform code
├── ios/                          # iOS platform code
└── web/                          # Web build config
```

## Usage

### Playing Samples

1. **Tap a pad** to trigger the assigned sample
2. **Long-press a pad** to import a new sample from your device
3. Use **Bank buttons (A-D)** to switch between sample banks

### Recording Audio

1. Tap the **🎤 Record** button in the control panel
2. Grant microphone permission when prompted
3. Tap **Record** again to stop
4. The recording is automatically saved to the last pad

### Bluetooth MIDI

1. Tap the **📶 Bluetooth** indicator in the header
2. Tap **SCAN** to search for MIDI devices
3. Select your device from the list
4. Pads will now send MIDI notes to connected devices

### Controls

- **BPM +/-** - Adjust tempo (60-200 BPM)
- **Play/Stop** - Transport control
- **Loop** - Toggle global loop mode

### Loading Default Samples

1. Tap **"Load Pack"** in the control panel
2. This loads preset drum names to Bank A

## JUCE Audio Engine

For low-latency audio on iOS/Android, the app includes a JUCE-based audio engine:

### Building JUCE (Optional - for native audio)

```bash
# Clone JUCE submodule
git submodule add https://github.com/juce-framework/JUCE.git native_audio/juce

# Build JUCE audio engine
cd native_audio
mkdir build && cd build
cmake .. -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0
cmake --build . --config Release
```

> **Note:** The Flutter `just_audio` package is used as the default audio backend. JUCE integration requires additional platform channel setup for production use.

## Sample Libraries

Free drum sample sources:

- [99Sounds Hip-Hop Drums](https://99sounds.org/free-drum-samples/)
- [Bedroom Producers Blog](https://bedroomproducersblog.com/free-drum-samples/)
- [SampleFocus](https://www.samplefocus.com/)

## Building for Production

### Web
```bash
flutter build web --release
```

### iOS
```bash
flutter build ios --release
```

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

## Troubleshooting

### Flutter not found
```bash
# Install Flutter
brew install --cask flutter

# Verify installation
flutter doctor
```

### Web build issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web
```

### Audio not playing (Web)
- Web browsers require user interaction before audio can play
- Tap any pad first to enable audio context

## Roadmap

- [ ] Arpeggiator with scale/mode selection
- [ ] Built-in effects (Reverb, Delay, Filter)
- [ ] Sample recording
- [ ] Pattern sequencer
- [ ] MIDI export/import
- [ ] Cloud sample library sync

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Credits

- Built with [Flutter](https://flutter.dev)
- Audio powered by [just_audio](https://pub.dev/packages/just_audio)
- Native audio engine based on [JUCE](https://juce.com)
- Sample UI inspired by classic drum machines (MPC, TR-808)

---

**Enjoy making beats! 🎵**
