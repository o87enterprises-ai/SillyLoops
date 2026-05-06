# SillyLoops - Traditional Sampler & Looper 🎹

A Flutter-based sampler and looper designed for simplicity and immediate creative flow. Record any sound and turn it into a loop instantly.

![SillyLoops](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)

## 🚀 The Looper Workflow

SillyLoops is designed to be as easy as a traditional looper pedal:

1.  **Select a Pad** - Tap any of the 8 pads to select it.
2.  **Record** - Tap the big **RECORD** button and start making sound.
3.  **Loop** - Tap **STOP** when you're done. The sound is instantly assigned to the pad and starts looping automatically.
4.  **Layer** - Select another pad and repeat to build your track.

## Features

- **8 Multi-Bank Pads** - 4 banks of 8 pads for a total of 32 sample slots.
- **Instant Looping** - Recordings default to loop mode for seamless layering.
- **Visual Feedback** - Pulsing red indicates recording; highlighted borders show selection.
- **BPM Control** - Sync your loops with an adjustable tempo.
- **Arpeggiator** - Turn your recorded loops into rhythmic patterns.
- **One-Tap Controls** - Clear, Loop, and Record functions are always one tap away.

## Quick Start

### Prerequisites

- **Flutter SDK** 3.0+

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/o87enterprises-ai/SillyLoops.git
cd SillyLoops
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Run the app:**
```bash
flutter run -d chrome  # For Web
# or
flutter run           # For Mobile
```

## Usage

### Recording a Loop

1. Tap an **Empty Pad**.
2. Tap the **RECORD** button in the control panel.
3. Make some noise!
4. Tap **STOP** to finish. The loop starts playing immediately.

### Managing Pads

- **Toggle Loop:** Tap the **Loop** button in the control panel or long-press the pad.
- **Clear Pad:** Select the pad and tap the **Clear** button.
- **Switch Banks:** Use the **A, B, C, D** buttons to access more pads.

## Technical Details

- **Audio Engine:** Powered by `just_audio` for reliable playback and `record` for high-quality sampling.
- **State Management:** Uses `Provider` for reactive UI updates and low-latency interaction.
- **Web Support:** Fully compatible with modern browsers (requires microphone permission).


---

**Enjoy making beats! 🎵**
