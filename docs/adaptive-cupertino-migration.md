# Adaptive Cupertino Widget Migration Guide

This document provides guidance for migrating shared widgets to support platform-adaptive behavior using Cupertino widgets on iOS/macOS.

## Overview

The goal is to provide native-feeling UI on each platform:
- **iOS/macOS**: Cupertino widgets (iOS design language)
- **Android/Web**: Material widgets (current implementation)

## Architecture

### Directory Structure

```
lib/shared/widgets/
├── adaptive/
│   ├── adaptive_loading_indicator.dart  ✅ DONE
│   ├── adaptive_error_widget.dart       ✅ DONE
│   ├── adaptive_button.dart             🔲 TODO
│   └── adaptive_card.dart               🔲 TODO
├── loading_indicator.dart               ✅ Updated (delegates to adaptive)
├── error_widget.dart                    ✅ Updated (delegates to adaptive)
├── app_button.dart                      🔲 TODO
└── app_card.dart                        🔲 TODO
```

### Platform Detection Pattern

Use this pattern in all adaptive widgets:

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

bool get _useCupertino => !kIsWeb && (Platform.isIOS || Platform.isMacOS);
```

## Completed Migrations

### 1. LoadingIndicator ✅

**File**: `lib/shared/widgets/adaptive/adaptive_loading_indicator.dart`

| Platform | Widget |
|----------|--------|
| iOS/macOS | `CupertinoActivityIndicator(radius: 14.0)` |
| Android/Web | `CircularProgressIndicator(color: AppTheme.primaryColor)` |

**Migration approach**: The original `LoadingIndicator` now delegates to `AdaptiveLoadingIndicator`, providing backward compatibility.

---

### 2. AppErrorWidget ✅

**File**: `lib/shared/widgets/adaptive/adaptive_error_widget.dart`

| Platform | Widget |
|----------|--------|
| iOS/macOS | `CupertinoIcons.exclamationmark_circle` + `CupertinoButton` |
| Android/Web | `Icons.error_outline` + `ElevatedButton` |

**Migration approach**: The original `AppErrorWidget` now delegates to `AdaptiveErrorWidget`, providing backward compatibility.

---

## Pending Migrations

### 2. AppButton (Medium Complexity)

**File**: `lib/shared/widgets/app_button.dart`

**Current Implementation**:
```dart
ElevatedButton(
  onPressed: isLoading ? null : onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? AppTheme.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    minimumSize: const Size(double.infinity, 48),
  ),
  child: isLoading
      ? CircularProgressIndicator(...)
      : Row(children: [icon, text]),
)
```

**Cupertino Equivalent**:
```dart
SizedBox(
  width: double.infinity,
  child: CupertinoButton.filled(
    onPressed: isLoading ? null : onPressed,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: isLoading
        ? CupertinoActivityIndicator(color: CupertinoColors.white)
        : Row(children: [icon, text]),
  ),
)
```

**Migration Notes**:
- `CupertinoButton.filled()` provides filled button style
- Loading spinner: swap `CircularProgressIndicator` for `CupertinoActivityIndicator`
- Full-width: wrap in `SizedBox(width: double.infinity)`
- Custom colors: Use `CupertinoButton` with custom `color` parameter
- Icon handling works the same way

**API Mapping**:

| AppButton Property | Material | Cupertino |
|--------------------|----------|-----------|
| `text` | `Text(text)` | `Text(text)` |
| `onPressed` | `onPressed` | `onPressed` |
| `isLoading` | `CircularProgressIndicator` | `CupertinoActivityIndicator` |
| `icon` | `Icon(icon)` | `Icon(icon)` (use CupertinoIcons if needed) |
| `backgroundColor` | `backgroundColor` | `color` parameter |

---

### 3. AppCard (Medium Complexity)

**File**: `lib/shared/widgets/app_card.dart`

**Current Implementation**:
```dart
Card(
  margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    ),
  ),
)
```

**Cupertino Equivalent**:
```dart
Container(
  margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: CupertinoColors.systemBackground.resolveFrom(context),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: CupertinoColors.systemGrey.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: onTap,
    child: Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    ),
  ),
)
```

**Migration Notes**:
- No direct Cupertino card equivalent - use styled `Container`
- Replace `InkWell` ripple with `CupertinoButton` opacity feedback
- Use `CupertinoColors.systemBackground` for adaptive background
- Shadow instead of Material elevation
- Consider using `GestureDetector` if button styling interferes with content

**Challenges**:
- Ripple effect vs opacity feedback (fundamental design difference)
- May need custom tap animation for iOS feel
- Text color inside CupertinoButton may need adjustment

---

---

## Migration Steps (Template)

Follow these steps for each widget:

### Step 1: Create Adaptive Widget

Create `lib/shared/widgets/adaptive/adaptive_<widget_name>.dart`:

```dart
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/config/theme.dart';

class Adaptive<WidgetName> extends StatelessWidget {
  // Copy all parameters from original widget

  const Adaptive<WidgetName>({super.key, /* params */});

  bool get _useCupertino => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    if (_useCupertino) {
      return _buildCupertino(context);
    }
    return _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    // Original Material implementation
  }

  Widget _buildCupertino(BuildContext context) {
    // New Cupertino implementation
  }
}
```

### Step 2: Update Original Widget

Update original widget to delegate to adaptive version:

```dart
import 'adaptive/adaptive_<widget_name>.dart';

class <WidgetName> extends StatelessWidget {
  // Keep same API

  @override
  Widget build(BuildContext context) {
    return Adaptive<WidgetName>(/* pass all params */);
  }
}
```

### Step 3: Test

```bash
# Analyze for errors
flutter analyze lib/shared/widgets/

# Run all tests
flutter test
```

---

## Cupertino Icons Reference

Common icon mappings for this project:

| Material Icon | Cupertino Icon |
|---------------|----------------|
| `Icons.error_outline` | `CupertinoIcons.exclamationmark_circle` |
| `Icons.search` | `CupertinoIcons.search` |
| `Icons.train` | `CupertinoIcons.tram_fill` |
| `Icons.schedule` | `CupertinoIcons.clock` |
| `Icons.swap_vert` | `CupertinoIcons.arrow_up_arrow_down` |
| `Icons.cloud` | `CupertinoIcons.cloud` |
| `Icons.sunny` | `CupertinoIcons.sun_max` |
| `Icons.navigation` | `CupertinoIcons.location` |

---

## Color Mapping

| AppTheme Color | Cupertino Equivalent |
|----------------|----------------------|
| `AppTheme.primaryColor` (SBB red) | Keep same or use `CupertinoColors.systemRed` |
| `AppTheme.errorColor` | `CupertinoColors.systemRed` |
| `Colors.white` | `CupertinoColors.white` |
| `Colors.grey` | `CupertinoColors.systemGrey` |
| Background | `CupertinoColors.systemBackground.resolveFrom(context)` |

---

## Testing Considerations

1. **Platform-specific tests**: Mock `Platform.isIOS` for testing Cupertino paths
2. **Visual regression**: Test on both iOS simulator and Android emulator
3. **Accessibility**: Ensure Cupertino widgets maintain accessibility features

---

## Recommended Migration Order

1. ~~LoadingIndicator~~ ✅ Complete
2. ~~AppErrorWidget~~ ✅ Complete
3. **AppButton** - Medium complexity, loading state handling
4. **AppCard** - Most complex, tap feedback differences
