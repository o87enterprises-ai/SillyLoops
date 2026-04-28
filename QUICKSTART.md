# SillyLoops - Quick Start Guide 🎹

## 🚀 Instant Play (No Installation Required)

**The app is now open in your browser!**

### File: `web/standalone.html`

This standalone version works immediately with synthesized sounds - no Flutter installation needed!

---

## 🎮 Controls

### Playing Sounds
- **Click/Tap pads** - Trigger drum sounds
- **Keyboard 1-8** - Play pads 1-8
- **Right-click pad** - Import your own sample

### Bank Navigation
- **Bank buttons A-D** - Switch between 4 sample banks
- **Keyboard Q, W, E, R** - Select banks 0-3
- **Arrow keys ◀ ▶** - Navigate banks

### Transport Controls
- **Play/Stop button** - Toggle playback status
- **Spacebar** - Play/Stop toggle
- **BPM +/-** - Adjust tempo (60-200 BPM)
- **Up/Down arrows** - Adjust BPM

### Loop Mode
- **⟳ button** - Toggle loop mode
- **L key** - Toggle loop mode
- When enabled, imported samples will loop

### Recording
- **🎤 Record button** - Start/stop microphone recording
- **Ctrl+R** - Quick record shortcut
- Recordings are saved to the last pad automatically
- Input level meter shows mic input in real-time

### Bluetooth MIDI
- **📶 Bluetooth button** - Open Bluetooth MIDI panel
- Scan for and connect MIDI controllers
- Pads send MIDI notes when played
- Works with Web MIDI-compatible devices

### Actions
- **📁 Import** - Load audio file to selected pad
- **🎤 Record** - Record from microphone
- **📶 Bluetooth** - Connect MIDI devices
- **📦 Load Pack** - Load default drum names to Bank A
- **✕ Clear** - Clear selected pad

---

## 📁 Importing Your Own Samples

1. **Right-click** (or long-press on mobile) any pad
2. Select an audio file (WAV, MP3, OGG, etc.)
3. The sample loads to that pad
4. Tap the pad to play your sample!

### Free Sample Sources
- [99Sounds Hip-Hop Drums](https://99sounds.org/free-drum-samples/)
- [Bedroom Producers Blog](https://bedroomproducersblog.com/free-drum-samples/)
- [SampleFocus](https://www.samplefocus.com/)
- [Cymatics Free Packs](https://cymatics.fm/pages/free-downloads)

---

## 🔧 Full Flutter Build (Optional)

For mobile apps (iOS/Android) with advanced features:

### Prerequisites
```bash
# Install Flutter (macOS)
brew install --cask flutter

# Verify installation
flutter doctor
```

### Build Commands
```bash
# Navigate to project
cd SillyLoops

# Download samples
./download_samples.sh

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Build for production web
flutter build web --release

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android
```

### Quick Launch Script
```bash
./setup_and_launch.sh
```

---

## 🎹 Default Drum Mapping (Bank A)

| Pad | Name | Sound |
|-----|------|-------|
| 1 | Kick | Low bass drum |
| 2 | Snare | Sharp snare hit |
| 3 | HiHat Closed | Short hi-hat |
| 4 | HiHat Open | Open hi-hat |
| 5 | Clap | Hand clap |
| 6 | Percussion | Tom/conga |
| 7 | Crash | Cymbal crash |
| 8 | Ride | Ride cymbal |

---

## 💡 Tips

1. **Layer sounds** - Quick-tap multiple pads for combinations
2. **Use banks** - Store different kits in banks A-D
3. **Loop mode** - Enable for sustained samples
4. **BPM sync** - Adjust tempo to match your project
5. **Keyboard shortcuts** - Use number keys for fast playing

---

## 🐛 Troubleshooting

### No Sound
- Click anywhere on the page first (browser audio policy)
- Check browser volume settings
- Ensure speakers/headphones are connected

### Import Not Working
- Try a different audio format (WAV recommended)
- Check file is not corrupted
- Use modern browser (Chrome, Firefox, Safari, Edge)

### Performance Issues
- Close other browser tabs
- Reduce number of loaded samples
- Use shorter audio files

---

## 📊 Project Structure

```
sillyloops/
├── web/
│   ├── standalone.html    ← Play this directly!
│   ├── index.html         ← Flutter web entry
│   └── manifest.json      ← PWA config
├── lib/                   ← Flutter app code
├── native_audio/          ← JUCE audio engine
├── assets/samples/        ← Drum samples
├── download_samples.sh    ← Sample downloader
├── setup_and_launch.sh    ← Full setup script
└── README.md              ← Full documentation
```

---

## 🎵 Enjoy Making Beats!

**SillyLoops** - Your retro ARP sampler for hip-hop drum machine goodness.

Built with ❤️ using Flutter + JUCE
