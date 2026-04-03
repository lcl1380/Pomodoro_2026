# 🍅 Pomodoro Cherish

A minimalist Pomodoro timer built with Flutter, designed for focus and customization.  
Windows · macOS · iPad · Android — single codebase.

---

## Screenshots

> _Add your screenshots here_

---

## Features

- **Circular progress ring** — fills as time passes, with smooth animation
- **MM:SS display** — clean digital clock style with a colored colon accent
- **Progress badge** — shows completion percentage inside the ring
- **Preset & custom duration** — 25 min / 50 min / up to 4 hours (240 min)
- **Completion sound** — plays a soft chime when the session ends
- **Color customization** — independently set ring color and UI accent color via a 2D HSV palette
  - Drag to pick, loupe preview while dragging
  - HEX code input with validation
  - Auto contrast text (WCAG-based) on buttons
- **Light / Dark mode toggle** — bottom-right icon, background-only switch
- **Custom app title** — supports Korean, English, and emoji
- **Minimum window size** — enforced at 420 × 560 px (Windows)

---

## Tech Stack

| | |
|---|---|
| Framework | [Flutter](https://flutter.dev) |
| State management | [Provider](https://pub.dev/packages/provider) |
| Fonts | [google_fonts](https://pub.dev/packages/google_fonts) — Space Grotesk · Manrope |
| Audio | [audioplayers](https://pub.dev/packages/audioplayers) |
| Windows installer | [msix](https://pub.dev/packages/msix) |

---

## Project Structure

```
lib/
├── main.dart
├── app_theme.dart              # Color tokens & auto-contrast utility
├── providers/
│   ├── timer_provider.dart     # Timer state, audio, color state
│   ├── theme_provider.dart     # Light / dark mode
│   └── title_provider.dart     # App title customization
├── screens/
│   ├── timer_screen.dart       # Main screen layout
│   └── settings_screen.dart    # Color picker + title editor
└── widgets/
    ├── timer_ring.dart         # Circular progress ring (CustomPaint)
    ├── preset_selector.dart    # Duration preset buttons
    └── color_picker.dart       # 2D HSV palette + sliders + HEX input
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.x`
- For Windows builds: Visual Studio 2022 with **Desktop development with C++**
- For iOS / iPadOS builds: macOS + Xcode + CocoaPods

### Run

```bash
flutter pub get
flutter run -d windows   # or macos / your-device-id
```

### Build

```bash
# Windows executable
flutter build windows --release

# Windows installer (.msix)
dart run msix:create

# iOS / iPadOS (macOS only)
cd ios && pod install && cd ..
flutter build ios --release
```

### Sound effect

Place your completion sound file at:

```
assets/sounds/complete.mp3
```

The app runs silently if the file is missing — no crash.

---

## Customization

All base colors are defined in `lib/app_theme.dart`:

```dart
class AppColors {
  static const primary      = Color(0xFF0ABBA1);
  static const primaryDim   = Color(0xFF009C85);
  static const primaryFixed = Color(0xFFBBFFF5);
  static const onPrimary    = Color(0xFF002D27);
  // ...
}
```

The initial ring / UI color in `lib/providers/timer_provider.dart`:

```dart
Color _ringColor = AppColors.primary;
Color _uiColor   = AppColors.primary;
```

---

## License

MIT
