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
swift run
```

## Build

```bash
swift build
```

## Build `.app` Bundle

```bash
chmod +x scripts/build_app.sh
./scripts/build_app.sh
```

This creates:

`Silent Timer.app`

## App Icon

- Source icon asset: `assets/AppIcon1024.png`
- The bundle script copies this into the app as `Contents/Resources/AppIcon.icns`

## Automated Checks

The repo includes GitHub Actions workflows that run automatically:

- `CI` (`.github/workflows/ci.yml`)
  - Runs on pushes to `main` and on pull requests
  - Executes `swift build`, `swift build -c release`, and `swift test` on `macos-latest`
- `CodeQL` (`.github/workflows/codeql.yml`)
  - Runs on pushes to `main`, pull requests to `main`, and weekly
  - Performs Swift code scanning and uploads results to GitHub Code Scanning
