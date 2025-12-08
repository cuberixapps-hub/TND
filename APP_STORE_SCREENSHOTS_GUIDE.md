# App Store Assets & Screenshots Guide

## 📸 Screenshots Required

You need to take screenshots for the following device sizes:

### Required Sizes:

1. **iPhone 6.5" Display** (iPhone 14 Pro Max, 15 Pro Max) - **REQUIRED**
   - Size: 1290 x 2796 pixels (portrait)
   - Minimum: 3 screenshots
   - Maximum: 10 screenshots

2. **iPhone 5.5" Display** (iPhone 8 Plus) - **REQUIRED**
   - Size: 1242 x 2208 pixels (portrait)
   - Minimum: 3 screenshots
   - Maximum: 10 screenshots

### Optional but Recommended:

3. **iPad Pro 12.9" Display**
   - Size: 2048 x 2732 pixels (portrait)
   - Minimum: 3 screenshots
   - Maximum: 10 screenshots

---

## 📱 How to Take Screenshots

### Method 1: Using iOS Simulator (Recommended)

```bash
# Open iOS Simulator with iPhone 15 Pro Max
flutter run -d "iPhone 15 Pro Max"

# Or manually open simulator
open -a Simulator

# In Simulator menu: File → Open Simulator → iPhone 15 Pro Max

# Take screenshot: Cmd + S (saves to Desktop)
# Or: Device → Trigger Screenshot
```

### Method 2: Using Physical Device

1. Connect iPhone to Mac
2. Run: `flutter run --release`
3. Take screenshots on device (Power + Volume Up)
4. AirDrop to Mac or use Image Capture app

---

## 🎯 Recommended Screenshots to Capture

Capture these screens in order (you can reuse them for all device sizes):

### 1. **Home Screen / Mode Selection** (Must Have)
   - Shows the main menu with all 4 game modes
   - Kids, Teens, Adult, Couples mode cards visible
   - Shows app branding and clean UI

### 2. **Player Setup** (Must Have)
   - Screen showing player addition interface
   - Shows 3-4 players added
   - Displays the "Add Player" functionality

### 3. **Game in Progress - Truth or Dare Selection** (Must Have)
   - Shows the spinning wheel or player selection
   - "Truth" and "Dare" buttons visible
   - Current player highlighted

### 4. **Challenge Display** (Recommended)
   - Shows an active challenge on screen
   - Example: "Tell everyone your most embarrassing moment"
   - Shows "Complete" and "Skip" buttons

### 5. **Scoreboard** (Recommended)
   - Shows the scoreboard with player scores
   - Displays rankings and points
   - Shows who's winning

### 6. **Custom Challenge Addition** (Optional)
   - Shows the interface for adding custom challenges
   - Demonstrates customization features
   - Shows difficulty selection

---

## 🎨 Screenshot Tips

1. **Use Clean Data**: Add sample players with fun names
   - Example: "Alex", "Sam", "Jordan", "Taylor"

2. **Show Diverse Content**: 
   - Mix of different screens
   - Various game modes (at least 2-3)
   - Different UI states

3. **High Quality**:
   - Always use release mode: `flutter run --release`
   - Take screenshots on fresh app launch
   - Ensure good lighting if using physical device

4. **Consistent Style**:
   - Same device orientation (portrait)
   - Same font rendering
   - Same time of day (if showing status bar)

---

## 📝 Screenshot Checklist

Before submitting, ensure you have:

- [ ] 3-10 screenshots for iPhone 6.5" (1290 x 2796)
- [ ] 3-10 screenshots for iPhone 5.5" (1242 x 2208)
- [ ] Screenshots show app in best light
- [ ] No personal information visible
- [ ] No copyrighted content (unless you own it)
- [ ] Screenshots are in PNG or JPEG format
- [ ] File size under 8MB each
- [ ] Screenshots are in order (most important first)

---

## 🎬 App Preview Video (Optional)

If you want to create a video preview:

- Duration: 15-30 seconds
- Show app flow: Home → Add Players → Play Game → Scoreboard
- No audio required (optional)
- Same dimensions as screenshots
- Can significantly increase conversion rate

### How to Record:

```bash
# Using iOS Simulator
# 1. Open Simulator
# 2. Run: xcrun simctl io booted recordVideo app_preview.mov
# 3. Use your app
# 4. Press Ctrl+C to stop recording
# 5. Edit video to 15-30 seconds
```

---

## 📊 Marketing Assets Summary

### App Store Connect Required:

| Asset | Size | Quantity | Required |
|-------|------|----------|----------|
| App Icon | 1024x1024 | 1 | ✅ Yes |
| iPhone 6.5" Screenshots | 1290x2796 | 3-10 | ✅ Yes |
| iPhone 5.5" Screenshots | 1242x2208 | 3-10 | ✅ Yes |
| iPad Screenshots | 2048x2732 | 3-10 | ⚠️ Optional |
| App Preview Video | 1290x2796 | 1-3 | ⚠️ Optional |

### Text Content Required:

| Field | Character Limit | Required |
|-------|----------------|----------|
| App Name | 30 | ✅ Yes |
| Subtitle | 30 | ✅ Yes |
| Description | 4000 | ✅ Yes |
| Keywords | 100 | ✅ Yes |
| Promotional Text | 170 | ⚠️ Optional |
| Support URL | - | ✅ Yes |
| Marketing URL | - | ⚠️ Optional |
| Privacy Policy URL | - | ✅ Yes |

---

## 🔧 Quick Commands

```bash
# Take screenshots on simulator
flutter run -d "iPhone 15 Pro Max"
# Then: Cmd + S in Simulator

# Take screenshots on different devices
flutter run -d "iPhone 8 Plus"
flutter run -d "iPad Pro (12.9-inch)"

# Build release version for testing
flutter run --release

# Open simulator
open -a Simulator

# List available simulators
xcrun simctl list devices
```

---

## 📤 Uploading Screenshots

1. Log in to App Store Connect: https://appstoreconnect.apple.com
2. Go to your app → App Store → [Version]
3. Scroll to **App Store Screenshots** section
4. Click the "+" button for each device size
5. Drag and drop your screenshots
6. Reorder them (most important first)
7. Screenshots can be different for each device size or the same

---

## ✅ Ready to Submit?

Once you have all screenshots and assets:

1. ✅ Launch images created
2. ✅ App icon configured (1024x1024)
3. ✅ 3+ screenshots for iPhone 6.5"
4. ✅ 3+ screenshots for iPhone 5.5"
5. ✅ Privacy policy URL ready
6. ✅ Support URL ready
7. ✅ App description written
8. ✅ Keywords selected

You're ready to archive and upload to App Store Connect! 🚀

---

## 🆘 Need Help?

If screenshots look wrong:
- Ensure you're running in `--release` mode
- Check device orientation (should be portrait)
- Verify resolution matches requirements
- Try restarting simulator/device

For more help:
- Apple Screenshot Guidelines: https://developer.apple.com/app-store/product-page/
- App Store Connect Help: https://help.apple.com/app-store-connect/

---

**Last Updated:** November 21, 2025


