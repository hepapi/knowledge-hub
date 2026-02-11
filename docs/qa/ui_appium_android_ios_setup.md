# Android & iOS Setup (Overview)

# Mobile Environment Setup

Environment setup is usually the most time-consuming part of mobile automation. A clean and stable configuration is critical for reliable tests.

## Android Setup

### Required Tools

- Android Studio
- Android SDK
- Java JDK
- `ANDROID_HOME` environment variable
- Emulator or real device with USB Debugging enabled

### Basic Steps

1. Install Android Studio.
2. Download:
   - Platform Tools
   - Build Tools
   - Emulator images
3. Set environment variables:

```bash
export ANDROID_HOME=/Users/username/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

4. Install Appium driver:

```bash
appium driver install uiautomator2
```

## iOS Setup (macOS only)

### Required Tools

- macOS
- Xcode
- Xcode Command Line Tools
- iOS Simulator
- Provisioning profiles for real devices

### Basic Steps

```bash
xcode-select --install
appium driver install xcuitest
```

Note: iOS setup is generally more complex due to signing and provisioning requirements.

