# App Icon Update Guide

This guide shows exactly where to place your app icons for both iOS and Android.

## iOS Icons

Place the following icon files in the directory:
`ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Required Icon Files and Sizes:

1. **Icon-App-20x20@1x.png** - 20x20 pixels
2. **Icon-App-20x20@2x.png** - 40x40 pixels
3. **Icon-App-20x20@3x.png** - 60x60 pixels
4. **Icon-App-29x29@1x.png** - 29x29 pixels
5. **Icon-App-29x29@2x.png** - 58x58 pixels
6. **Icon-App-29x29@3x.png** - 87x87 pixels
7. **Icon-App-40x40@1x.png** - 40x40 pixels
8. **Icon-App-40x40@2x.png** - 80x80 pixels
9. **Icon-App-40x40@3x.png** - 120x120 pixels
10. **Icon-App-60x60@2x.png** - 120x120 pixels
11. **Icon-App-60x60@3x.png** - 180x180 pixels
12. **Icon-App-76x76@1x.png** - 76x76 pixels
13. **Icon-App-76x76@2x.png** - 152x152 pixels
14. **Icon-App-83.5x83.5@2x.png** - 167x167 pixels
15. **Icon-App-1024x1024@1x.png** - 1024x1024 pixels (App Store)

## Android Icons

Place the following icon files in their respective directories under:
`android/app/src/main/res/`

### Required Icon Files and Locations:

1. **mipmap-mdpi/ic_launcher.png** - 48x48 pixels
2. **mipmap-hdpi/ic_launcher.png** - 72x72 pixels
3. **mipmap-xhdpi/ic_launcher.png** - 96x96 pixels
4. **mipmap-xxhdpi/ic_launcher.png** - 144x144 pixels
5. **mipmap-xxxhdpi/ic_launcher.png** - 192x192 pixels

## Icon Design Guidelines

1. **Format**: Use PNG format with transparency if needed
2. **Shape**:
   - iOS: Square icons (system will apply rounded corners)
   - Android: Can be square or follow Material Design guidelines
3. **Safe Zone**: Keep important content within 80% of the icon area
4. **Colors**: Use colors that work well on both light and dark backgrounds

## Quick Icon Generation Tips

If you have a single high-resolution icon (1024x1024), you can use online tools or scripts to generate all required sizes:

1. **Online Tools**:

   - https://appicon.co/ - Generates all sizes for iOS and Android
   - https://makeappicon.com/ - Free icon generator

2. **Command Line** (using ImageMagick):
   ```bash
   # Example for generating 120x120 icon
   convert original_icon.png -resize 120x120 Icon-App-60x60@2x.png
   ```

## After Placing Icons

Once you've placed all the icon files in their respective locations:

1. **iOS**: Clean and rebuild the project in Xcode
2. **Android**: Clean and rebuild the project
3. **Flutter**: Run `flutter clean` and then `flutter build`

## Verification

To verify the icons are properly set:

- iOS: Check in Xcode > Runner > General > App Icons and Launch Screen
- Android: Check in Android Studio or look at the app on device
