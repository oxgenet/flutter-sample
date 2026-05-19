# maestro_app

Flutter app scaffolded for Maestro UI testing.

## Prerequisites

- Flutter SDK
- Maestro CLI
- Android emulator or iOS Simulator

## Run the app

```bash
cd /Users/taka/Documents/flutter/maestro
flutter pub get
flutter run
```

## Run Maestro

```bash
export PATH="$PATH:$HOME/.maestro/bin"
cd /Users/taka/Documents/flutter/maestro
maestro test .maestro/launch_and_increment.yaml
```

The sample flow launches the app, taps the increment button, and verifies the counter changed from 0 to 1.
The flow taps the button through its accessibility label `Increment counter button`, so it is no longer tied to screen coordinates.
