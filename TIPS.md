# Flutter + Maestro Tips

This directory is set up for launching a Flutter app on iOS Simulator and running E2E tests with Maestro.

## Current setup

- Flutter project location: `/Users/taka/Documents/flutter/maestro`
- Flutter SDK: `/opt/homebrew/bin/flutter`
- Dart: `/opt/homebrew/bin/dart`
- Maestro CLI: `$HOME/.maestro/bin/maestro`
- iOS bundle id: `com.example.maestroApp`
- Sample flow: `/Users/taka/Documents/flutter/maestro/.maestro/launch_and_increment.yaml`

## Quickest run procedure

1. Launch the Simulator.

```bash
export PATH="$PATH:$HOME/.maestro/bin"
maestro start-device --platform=ios --device-model=iPhone-15-Pro --device-os=iOS-17-5
```

2. Check connected devices.

```bash
cd /Users/taka/Documents/flutter/maestro
/opt/homebrew/bin/flutter devices
```

3. Launch the Flutter app.

```bash
cd /Users/taka/Documents/flutter/maestro
/opt/homebrew/bin/flutter run -d 8C4355FC-415E-40D8-AA4C-4FA022531B2B
```

4. Run Maestro in a separate terminal.

```bash
export PATH="$PATH:$HOME/.maestro/bin"
cd /Users/taka/Documents/flutter/maestro
maestro test .maestro/launch_and_increment.yaml
```

## About device IDs

- `8C4355FC-415E-40D8-AA4C-4FA022531B2B` is the device id of the iPhone 15 Pro Simulator used this time.
- It changes if you recreate the Simulator, so always use the result of `flutter devices` rather than a hard-coded value.

## About bundle IDs

- Maestro's `appId` does not always match the Android `applicationId` and iOS bundle id.
- In this project the actual iOS bundle id is `com.example.maestroApp`.
- Location to verify:
  `/Users/taka/Documents/flutter/maestro/ios/Runner.xcodeproj/project.pbxproj`

## Flutter implementation rules

- Attach `Semantics` to elements that Maestro will interact with instead of relying on coordinate taps.
- The increment button in this project follows this approach in [main.dart](/Users/taka/Documents/flutter/maestro/lib/main.dart):
  - Wrap the entire FAB with `Semantics`
  - Add `excludeSemantics: true`
  - Add `identifier: 'increment-counter-button'`
  - Add `label: 'Increment counter button'`
- Attaching semantics only to the child `Text` can cause labels to merge in the iOS hierarchy, making Maestro unstable.

### Concrete Flutter example

- Attach `Semantics` to "the whole widget that is actually pressed", not to "the child `Text`".
- For clearly interactive widgets like `FloatingActionButton`, `ElevatedButton`, `TextField`, and `Switch`, wrap the widget itself with `Semantics` from the outside.
- If labels get mixed up on iOS, use `excludeSemantics: true` to suppress semantics from inner elements.
- Make `label` a human-readable string. Here: `Increment counter button`.
- Make `identifier` a stable code-friendly ID. Here: `increment-counter-button`.
- Keep `label` and `identifier` roles separate.
  - `label`: Easy to use in Maestro's `tapOn` and `assertVisible`
  - `identifier`: For checking in hierarchy; also reusable with other tools
- Don't rely solely on `tooltip` or displayed `Text` as the selector basis — UI text changes will break flows.

### Patterns to avoid in Flutter

- Design where `Text('Save')` is tapped as `tapOn: 'Save'`
  - Breaks when text is renamed
- Design where `Semantics` is attached only to the `Text` inside a button
  - Parent-child labels tend to merge on iOS
- Design where `ValueKey` alone is used
  - Valid in Flutter tests but may not be picked up directly by Maestro
- Design where coordinate taps are used from the start
  - Breaks with screen size changes or Safe Area variations

### Additional Flutter implementation examples

```dart
Semantics(
  button: true,
  container: true,
  excludeSemantics: true,
  identifier: 'login-submit-button',
  label: 'Login submit button',
  child: ElevatedButton(
    onPressed: _submit,
    child: const Text('Log in'),
  ),
)
```

```dart
Semantics(
  textField: true,
  container: true,
  identifier: 'email-input',
  label: 'Email input',
  child: TextField(
    controller: emailController,
  ),
)
```

### What to do every time you change Flutter code

```bash
cd /Users/taka/Documents/flutter/maestro
/opt/homebrew/bin/dart format lib/main.dart
/opt/homebrew/bin/flutter analyze
/opt/homebrew/bin/flutter test
```

Then redo `flutter run` and use `maestro hierarchy` to verify that labels and identifiers appear as expected.

## How to check Maestro selectors

- Inspect the UI hierarchy:

```bash
export PATH="$PATH:$HOME/.maestro/bin"
maestro hierarchy
```

- Filter to just the node you want:

```bash
export PATH="$PATH:$HOME/.maestro/bin"
maestro hierarchy | rg "Increment counter button|increment-counter-button|Counter: 0"
```

- On a successful run, the hierarchy confirmed:
  - `accessibilityText: "Increment counter button"`
  - `resource-id: "increment-counter-button"`

## Maestro implementation rules

- Use the ID actually installed on that platform for `appId`.
  - iOS: bundle id
  - Android: applicationId
- Start flows with `launchApp` and a minimal `assertVisible`.
- Prefer `tapOn: '<accessibility label>'` over coordinate taps.
- Write `assertVisible` checks short and reliably.
- Don't pack too much into one flow — split by screen or feature.

### What this flow does

```yaml
appId: com.example.maestroApp
---
- launchApp
- assertVisible: 'Counter: 0'
- tapOn: 'Increment counter button'
- assertVisible: 'Counter: 1'
```

- `launchApp`
  - Confirms app launch. If this fails, check `appId`
- `assertVisible: 'Counter: 0'`
  - Confirms the initial screen is showing
- `tapOn: 'Increment counter button'`
  - Taps using the Flutter-side semantics label
- `assertVisible: 'Counter: 1'`
  - Confirms the operation result

### Maestro debugging steps

1. If `launchApp` fails, check `appId`.
2. If an element can't be found, look at `maestro hierarchy`.
3. Rewrite `tapOn` or `assertVisible` using the strings visible in hierarchy.
4. If still unstable, fix the `Semantics` setup on the Flutter side.
5. Use coordinate taps only as a last resort.

### Common Maestro gotchas

- `tapOn` doesn't automatically use Flutter's `ValueKey`.
- On iOS, the visible text of a Flutter widget may not match `accessibilityText` in the hierarchy.
- Adding `label` only to a child element can cause `label + text` to merge in the hierarchy, making it impossible to target by the expected string alone.
- Use `maestro list-devices`, not `maestro devices`.
- `maestro start-device` requires `--platform=ios` or similar.

### Maestro check commands

```bash
export PATH="$PATH:$HOME/.maestro/bin"
maestro list-devices
```

```bash
export PATH="$PATH:$HOME/.maestro/bin"
maestro hierarchy
```

```bash
export PATH="$PATH:$HOME/.maestro/bin"
cd /Users/taka/Documents/flutter/maestro
maestro test .maestro/launch_and_increment.yaml
```

### Minimum rules when creating a new flow

- Start with 1 screen, 1 success case
- Put an `assertVisible` for the initial display right after `launchApp`
- Specify interaction targets using semantics label
- Put a final result-checking `assertVisible`
- On failure, look at hierarchy before fixing the flow

## Common pitfalls

- An old `flutter` can crash on the Dart VM at startup. This time Homebrew's Flutter 2.5.3 was broken and updated to 3.41.6.
- The Homebrew `maestro` cask can fail with a checksum mismatch. In that case, use the official installer.

```bash
curl -Ls https://get.maestro.mobile.dev | bash
```

- Use `maestro list-devices`, not `maestro devices`.
- `maestro start-device` requires `--platform`.

## Verification commands

```bash
cd /Users/taka/Documents/flutter/maestro
/opt/homebrew/bin/dart format lib/main.dart
/opt/homebrew/bin/flutter analyze
/opt/homebrew/bin/flutter test
```

## Guidelines for changes

- When adding buttons or input fields, attach a unique semantics label to each element Maestro will interact with.
- On the Maestro flow side, prefer label-based `tapOn` over coordinates.
- If a flow fails, first check `appId` and `maestro hierarchy`.

## ex2A additional notes (upper/lower 2-list + edit panel)

- Project:
  `/Users/taka/Documents/flutter/maestro/ex2A`
- iOS bundle id:
  `com.example.ex2aApp`
- Representative flow:
  `/Users/taka/Documents/flutter/maestro/ex2A/.maestro/complex_lists.yaml`

### ex2A verification commands

```bash
cd /Users/taka/Documents/flutter/maestro/ex2A
/opt/homebrew/bin/dart format lib/main.dart test/widget_test.dart
/opt/homebrew/bin/flutter analyze
/opt/homebrew/bin/flutter test
```

```bash
export PATH="$PATH:$HOME/.maestro/bin"
cd /Users/taka/Documents/flutter/maestro/ex2A
maestro test .maestro/complex_lists.yaml
```

### ex2A design points

- The linkage between upper and lower list is also verifiable via the `Status:` text.
- Tapping a lower item's `onTap` opens the edit bottom sheet (`Item editor panel`).
- After editing, `Save and close` updates the status text; `Show done` lets you verify show/hide.
- The Maestro side runs on English text and uses semantics labels (`board:...`, `item:...`) only where needed.
