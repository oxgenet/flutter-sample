# Keyboard.md

Practical notes for stabilizing keyboard operations with Flutter + Maestro.  
This file prioritizes "OS keyboard state synchronization" above all else.

---

## 1. Key prerequisites

- Maestro's `inputText` **does not support Unicode character input on Android** (e.g., Japanese)  
  - Official: `inputText` docs, Android Native docs
- `hideKeyboard` mimics OS behavior and **can fail**
  - Android: equivalent to a back event
  - iOS: small swipe at screen center
- Flutter's `TextInputAction` does not map 1:1 between iOS and Android
  - Example: `previous` is inappropriate on iOS
  - Example: `continueAction` is inappropriate on Android

---

## 2. Basic strategy for syncing OS keyboard state

1. Fix the start state with `launchApp: { clearState: true }`.
2. Explicitly `tapOn` the target field before input to set focus.
3. Absorb keyboard confirm keys with **multiple candidates** (`done` / `完了` / `Complete`).
4. For cases where `hideKeyboard` fails, tap a non-input area (header, etc.) with `tapOn`.
5. iOS devices/simulators retain the previous input mode, so sync within each flow.

---

## 3. Flutter implementation guidelines (important)

### 3.1 Choose `TextInputAction` assuming platform differences

- Mid-form: `TextInputAction.next`
- Final field: `TextInputAction.done`
- Avoid overusing `previous` / `continueAction` etc. due to platform differences

### 3.2 Attach semantics for testing

```dart
Semantics(
  textField: true,
  label: 'Email input',
  child: TextField(
    controller: _emailController,
    textInputAction: TextInputAction.done,
  ),
)
```

```dart
Semantics(
  button: true,
  label: 'Submit button',
  child: FilledButton(
    onPressed: _submit,
    child: const Text('Submit'),
  ),
)
```

---

## 4. Maestro flow pattern collection

### 4.1 Basic: input + confirm key absorption

```yaml
- tapOn: 'Email input'
- eraseText
- inputText: 'alice@example.com'
- runFlow:
    when:
      visible: done
    commands:
      - tapOn: done
- runFlow:
    when:
      visible: 完了
    commands:
      - tapOn: 完了
- runFlow:
    when:
      visible: Complete
    commands:
      - tapOn: Complete
```

### 4.2 Safety fallback when `hideKeyboard` fails

```yaml
- hideKeyboard
- runFlow:
    when:
      visible: 'Japanese input'
    commands:
      - tapOn: 'Status: empty'   # Tap a non-input area
```

### 4.3 Workaround for "conversion button not visible" on iOS

```yaml
- tapOn: 'Japanese input'
- inputText: ありす
- tapOn: 'Status: empty'      # Intend to close keyboard
- tapOn: 'Convert to Kanji'
- assertVisible: 'Status: converted ありす to 有栖'
```

### 4.4 Branch to work around Android Unicode limitation

```yaml
- runFlow:
    when:
      platform: android
    commands:
      - inputText: alice   # ASCII only
- runFlow:
    when:
      platform: ios
    commands:
      - inputText: ありす
```

### 4.5 Absorbing keyboard mode mismatch (example)

```yaml
- tapOn: 'English input'
- runFlow:
    when:
      visible: ABC
    commands:
      - tapOn: ABC
- runFlow:
    when:
      visible: 'Next keyboard'
    commands:
      - tapOn: 'Next keyboard'
```

---

## 5. iOS-specific tips

- iOS tends to retain the previous keyboard state. `clearState` alone may not align the mode.
- On iOS, the confirm key display can be a mix of `done` / `完了` / `Complete` depending on environment.
- `hideKeyboard` can fail, so always provide a header-tap fallback.
- `launchApp`'s `clearKeychain: true` is valid on iOS (useful for initializing auth tests).

---

## 6. Android-specific tips

- The most critical constraint is that `inputText` doesn't support Unicode. Absorb Japanese direct-input tests in design.
- Android IME actions map to `EditorInfo`'s `IME_ACTION_DONE` / `IME_ACTION_NEXT`.
- `hideKeyboard` is equivalent to back, so watch for conflicts with screen transitions.

---

## 7. Practical template for ex1B

```yaml
appId: com.example.ex1bApp
---
- launchApp:
    clearState: true
- tapOn: 'Japanese input'
- eraseText
- inputText: ありす
- tapOn: 'Status: empty'
- tapOn: 'Convert to Kanji'
- tapOn: 'English input'
- eraseText
- inputText: alice
- tapOn: 'Email input'
- eraseText
- inputText: 'alice@example.com'
- tapOn: 'Submit'
- assertVisible: '有栖'
- assertVisible: 'alice'
- assertVisible: 'alice@example.com'
```

---

## 8. Research sources (official)

- Maestro `inputText`  
  https://docs.maestro.dev/reference/commands-available/inputtext
- Maestro Android Native (Known limitations)  
  https://docs.maestro.dev/get-started/supported-platform/android/android-native
- Maestro `hideKeyboard`  
  https://docs.maestro.dev/reference/commands-available/hidekeyboard
- Maestro `launchApp`  
  https://docs.maestro.dev/reference/commands-available/launchapp
- Flutter `TextInputAction`  
  https://api.flutter.dev/flutter/flutter_test/TextInputAction.html
- Flutter `TextField.textInputAction`  
  https://api.flutter.dev/flutter/material/TextField/textInputAction.html
- Android `EditorInfo` (`IME_ACTION_DONE`, `IME_ACTION_NEXT`)  
  https://developer.android.com/reference/android/view/inputmethod/EditorInfo
- Android `TextView.OnEditorActionListener`  
  https://developer.android.com/reference/android/widget/TextView.OnEditorActionListener
