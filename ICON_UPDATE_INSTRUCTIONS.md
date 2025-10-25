# Truth or Dare App Icon Update Instructions

## Step 1: Save the Icon

Save the Truth or Dare icon image (the one with the green bottle and blue background) as:

```
app_icon.png
```

in the root directory of your project:

```
/Users/chandangadhavi11/Documents/Cuberix/Games/Marcos/TruthOrDare/truth_or_dare/app_icon.png
```

## Step 2: Generate All Icon Sizes

Once you've saved the icon, run this command in your terminal from the project root:

```bash
./generate_icons_macos.sh app_icon.png
```

This will automatically:

- Generate all 15 required iOS icon sizes
- Generate all 5 required Android icon sizes
- Place them in the correct directories

## Step 3: Clean and Rebuild

After the icons are generated, run:

```bash
flutter clean
flutter pub get
```

## Step 4: Verify the Icons

- **iOS**: Open `ios/Runner.xcworkspace` in Xcode and check Runner > General > App Icons
- **Android**: The icons will be visible when you build and install the app

## Icon Locations After Generation

### iOS Icons

All icons will be in: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Android Icons

Icons will be distributed in:

- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

## Alternative: Manual Icon Generation

If you prefer to use an online tool:

1. Go to https://appicon.co/
2. Upload your Truth or Dare icon
3. Download the generated icons
4. Place them in the locations specified in `APP_ICON_GUIDE.md`
