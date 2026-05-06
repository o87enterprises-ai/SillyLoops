# How to Run SillyLoops Locally

## Prerequisites

Before running SillyLoops, you'll need to install Flutter on your local machine.

### For macOS:

1. Install Flutter using Homebrew:
   ```bash
   brew install --cask flutter
   ```

2. Add Flutter to your PATH (add this to your shell profile like ~/.zshrc or ~/.bash_profile):
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. Run Flutter doctor to verify installation:
   ```bash
   flutter doctor
   ```

### For Windows/Linux:

Follow the official installation guide: https://docs.flutter.dev/get-started/install

## Running SillyLoops

After installing Flutter:

1. Make sure you're in the SillyLoops directory:
   ```bash
   cd SillyLoops
   ```

2. Download drum samples (if not already done):
   ```bash
   ./download_samples.sh
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   - For Web (recommended for easiest setup):
     ```bash
     flutter run -d chrome
     ```
   - For iOS simulator:
     ```bash
     flutter run -d ios
     ```
   - For Android emulator:
     ```bash
     flutter run -d android
     ```

## Alternative: Quick Setup Script

You can also run our provided setup script which handles everything:

```bash
./setup_and_launch.sh
```

## Troubleshooting

If you encounter issues:

1. Make sure all scripts are executable:
   ```bash
   chmod +x *.sh
   ```

2. If web build fails, try:
   ```bash
   flutter config --enable-web
   ```

3. For audio issues on web, remember you need to interact with the page first (click anywhere) before audio will play.

Enjoy making beats with SillyLoops! 🎵