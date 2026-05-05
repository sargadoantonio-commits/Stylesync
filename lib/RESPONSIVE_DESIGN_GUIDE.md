# StyleSync Responsive Design Guidelines

## Overview
This document outlines the responsive design approach for StyleSync, ensuring all UI elements adapt properly to different screen sizes from small phones (320px) to large tablets (1200px+).

## Responsive Breakpoints
The app uses five screen size categories:
- **ExtraSmall**: < 480px (old phones, iPhone SE)
- **Small**: 480px - 599px (most phones)
- **Medium**: 600px - 839px (large phones, small tablets)
- **Large**: 840px - 1199px (tablets)
- **ExtraLarge**: 1200px+ (large tablets, desktop)

## Using ResponsiveHelper

### Get Screen Size
```dart
final screenSize = ResponsiveHelper.getScreenSize(context);
```

### Get Responsive Values
```dart
// Padding/spacing that scales with screen
final padding = ResponsiveHelper.getResponsivePadding(context);

// Border radius that adapts
final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);

// Font sizes that scale
final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);

// Spacing that scales
final spacing = ResponsiveHelper.getResponsiveSpacing(context, 16);

// Button heights that adapt
final buttonHeight = ResponsiveHelper.getResponsiveButtonHeight(context);

// Max content width for large screens (centers content on tablets)
final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
```

### Check Device Type
```dart
if (ResponsiveHelper.isSmallDevice(context)) {
  // Show single column layout
} else if (ResponsiveHelper.isTablet(context)) {
  // Show multi-column layout
}
```

## Responsive Widgets

### ResponsiveCard
Automatically adjusts padding and border radius based on screen size.

```dart
ResponsiveCard(
  child: Column(
    children: [
      Text("Title"),
      SizedBox(height: 12),
      Text("Content"),
    ],
  ),
)
```

### ResponsiveButton
Scales button size and text automatically.

```dart
ResponsiveButton(
  label: "Confirm",
  onPressed: () {},
  icon: Icons.check,
  enabled: true,
)
```

### ResponsiveSpacer
Provides proportional spacing.

```dart
ResponsiveSpacer(baseHeight: 16, factor: 1.5)
```

### ResponsiveGrid
Adapts column count based on screen size.

```dart
ResponsiveGrid(
  children: [item1, item2, item3],
)
```

## Common Patterns

### Vertical Stacking on Small Screens
```dart
ResponsiveHelper.isSmallDevice(context)
    ? Column(
        children: [
          button1,
          SizedBox(height: spacing),
          button2,
        ],
      )
    : Row(
        children: [
          Expanded(child: button1),
          SizedBox(width: spacing),
          Expanded(child: button2),
        ],
      )
```

### Responsive Padding
```dart
Padding(
  padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
  child: child,
)
```

### Responsive List with Max Width
```dart
ListView(
  children: [
    Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ResponsiveHelper.getMaxContentWidth(context)),
        child: card,
      ),
    ),
  ],
)
```

## Best Practices

1. **Always use ResponsiveHelper** for dimensions, not hard-coded values
2. **Wrap content-heavy screens** with `ConstrainedBox(maxWidth: ...)` to prevent text overflow
3. **Use `SingleChildScrollView` or `ListView`** with proper padding for scrollable screens
4. **Test on multiple screen sizes**: Extra small (320-480), Small (480-600), Medium (600-840)
5. **Use `Expanded` and `Flexible`** in rows/columns for proper flex distribution
6. **Scale font sizes appropriately** - don't assume 16 is always readable
7. **Test on actual devices** - emulator scaling can be misleading

## Migration Checklist

When updating an existing screen, ensure:
- [ ] Import `responsive_helper.dart`
- [ ] Replace hard-coded `padding` with `ResponsiveHelper.getResponsivePadding(context)`
- [ ] Replace hard-coded `SizedBox(height: X)` with responsive equivalents
- [ ] Replace hard-coded button heights with `ResponsiveHelper.getResponsiveButtonHeight(context)`
- [ ] Add `maxWidth` constraints to card-based layouts
- [ ] Test on small (< 480px), medium (600px), and large (>1000px) screens
- [ ] Verify text doesn't overflow with ellipsis or FittedBox

## Recently Updated Screens

The following screens have been updated with responsive design:
1. **auth_screen.dart** - Full responsive auth with adaptive logo, buttons, and spacing
2. **profile_setup_screen.dart** - Responsive form with adaptive card width
3. **booking_screen.dart** - Responsive date/time picker (stacked on small screens, side-by-side on large)

## Testing

Run on different screen sizes:
```bash
flutter run -d chrome --web-renderer=canvaskit
# Resize browser window to test responsiveness
```

Or test on Android emulator with different device profiles from Android Studio.
