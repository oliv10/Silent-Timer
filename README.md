# Silent Timer (Swift + AppKit Status Bar)

Native macOS status bar timer app built with Swift and AppKit.

## Features

- Status bar timer icon (native SF Symbol)
- Preset timers: 5, 15, 30 minutes, and 1 hour
- Custom timer input with a native glass-style `hr:min:sec` modal and editable digits
- Live countdown shown in status bar title
- Stop timer action
- Native macOS alert when timer finishes

## Run

```bash
cd "/Users/oliver.scotten/Documents/DevEnv/Silent Timer"
swift run
```

## Build

```bash
cd "/Users/oliver.scotten/Documents/DevEnv/Silent Timer"
swift build
```

## Build `.app` Bundle

```bash
cd "/Users/oliver.scotten/Documents/DevEnv/Silent Timer"
chmod +x scripts/build_app.sh
./scripts/build_app.sh
```

This creates:

`Silent Timer.app`

## App Icon

- Source icon asset: `assets/AppIcon1024.png`
- The bundle script copies this into the app as `Contents/Resources/AppIcon.icns`
