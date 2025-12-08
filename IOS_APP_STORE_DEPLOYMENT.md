# iOS App Store Deployment Guide for Truth or Dare

This guide will walk you through the complete process of uploading your Truth or Dare app to the iOS App Store.

## 📋 Current App Configuration

**App Name:** Truth or Dare  
**Bundle ID:** com.cuberix.truthordare  
**Version:** 1.0.1 (Build 2)  
**Team ID:** BJC5J6L379  

---

## ✅ Prerequisites Checklist

Before you begin, ensure you have:

- [ ] **Apple Developer Account** ($99/year)
  - Enroll at: https://developer.apple.com/programs/enroll/
  - Your team ID (BJC5J6L379) is already configured

- [ ] **Mac with Xcode** (Latest version recommended)
  - Download from Mac App Store
  - Minimum Xcode 14.0+ required

- [ ] **Valid Apple ID** with Two-Factor Authentication enabled

- [ ] **App Store Connect Access**
  - Access at: https://appstoreconnect.apple.com

---

## 🎯 Step-by-Step Deployment Process

### Phase 1: Prepare App Information

#### 1.1 Verify App Configuration

Your current configuration:
- ✅ Bundle ID is set: `com.cuberix.truthordare`
- ✅ Development Team is configured: `BJC5J6L379`
- ✅ Version is set: `1.0.1+2`
- ✅ AdMob is configured with proper IDs

#### 1.2 Update App Description (if needed)

The current description in `pubspec.yaml` is generic. Consider updating it to:

```yaml
description: "Truth or Dare - The ultimate party game with multiple modes for kids, teens, adults, and couples. Play with up to 20 players!"
```

### Phase 2: Prepare Marketing Materials

#### 2.1 App Store Assets Required

You'll need to prepare the following **before** submitting:

**App Icon:**
- ✅ Already configured in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Sizes: 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024 (all @2x and @3x where applicable)

**Screenshots Required:**
- **6.5" iPhone** (iPhone 14 Pro Max, 15 Pro Max) - 1290 x 2796 pixels - REQUIRED
- **5.5" iPhone** (iPhone 8 Plus) - 1242 x 2208 pixels - REQUIRED
- **12.9" iPad Pro** (optional but recommended) - 2048 x 2732 pixels
- **Minimum:** 3 screenshots, **Maximum:** 10 screenshots per device size

**App Preview Video (Optional but Recommended):**
- Up to 30 seconds
- Same sizes as screenshots

#### 2.2 Take Screenshots

**Method 1: Using iOS Simulator**

```bash
# Open iOS Simulator
open -a Simulator

# Launch your app
flutter run

# Take screenshots with: Cmd + S (saves to Desktop)
# Or use: Device > Trigger Screenshot
```

**Method 2: Using Physical Device**
- Run app on physical iPhone
- Take screenshots (Power + Volume Up)
- AirDrop or transfer to Mac

**Required Screenshots to Capture:**
1. Home screen with game mode selection
2. Player setup screen
3. Game in progress (spinning wheel or challenge display)
4. Scoreboard/leaderboard
5. Custom challenge addition screen (optional)

#### 2.3 Prepare App Store Listing Content

Create a document with the following information:

**App Name (30 characters max):**
```
Truth or Dare: Party Game
```

**Subtitle (30 characters max):**
```
Fun Challenges for Everyone
```

**Description (4000 characters max):**
```
🎉 Truth or Dare - The Ultimate Party Game!

Make your parties unforgettable with the most feature-rich Truth or Dare app! Perfect for gatherings, date nights, family time, or any social occasion.

🌟 FEATURES:

✨ FOUR GAME MODES
• Kids Mode 👶 - Safe, fun challenges for ages 7-12
• Teens Mode 🎉 - Perfect for teenage parties (13-17)
• Adult Mode 🔥 - Spicy challenges for 18+ gatherings
• Couples Mode 💕 - Romantic challenges for date nights

👥 UP TO 20 PLAYERS
• Add 2-20 players with custom names
• Drag to reorder players
• Track individual scores
• Real-time leaderboard

🎯 HUNDREDS OF CHALLENGES
• Pre-loaded truths and dares for each mode
• Add your own custom challenges
• Difficulty ratings (1-5 stars)
• No internet required - fully offline

🎨 BEAUTIFUL DESIGN
• Modern, trendy interface
• Smooth animations
• Spinning wheel selection
• Gradient backgrounds

📊 SCORING SYSTEM
• +10 points for truth completed
• +15 points for dare completed
• -5 points for skipping
• Live scoreboard updates

🎲 HOW TO PLAY:
1. Select your game mode
2. Add 2-20 players
3. Spin to select a player
4. Choose Truth or Dare
5. Complete the challenge or skip
6. Track scores and crown the winner!

💝 PERFECT FOR:
• House parties
• Date nights
• Road trips
• Sleepovers
• Family gatherings
• Icebreaker games
• Team building

🔒 PRIVACY & SAFETY:
• No account required
• No data collection
• Age-appropriate content for each mode
• Parental supervision recommended for younger players

Download now and start the fun! 🎊

Note: This app contains in-app purchases to remove ads and unlock premium features.
```

**Keywords (100 characters max, comma-separated):**
```
truth or dare,party game,drinking game,fun,challenges,teens,adult,couples,multiplayer,icebreaker
```

**Promotional Text (170 characters max):**
```
🎉 Make your parties unforgettable! Play Truth or Dare with up to 20 friends. Multiple modes: Kids, Teens, Adult & Couples. Download FREE today!
```

**Support URL:**
```
https://cuberix.com/support
# OR create a simple GitHub Pages site with contact info
```

**Marketing URL (optional):**
```
https://cuberix.com/truthordare
```

**Privacy Policy URL (REQUIRED):**
```
https://cuberix.com/privacy
# You MUST create this before submitting
```

**App Category:**
- Primary: Games
- Secondary: Entertainment

**Content Rating:**
- You'll need to complete a questionnaire in App Store Connect
- Expected rating: 12+ or 17+ (due to Adult/Couples modes)

---

### Phase 3: Configure Code Signing & Certificates

#### 3.1 Open Project in Xcode

```bash
cd /Users/chandangadhavi11/Documents/Cuberix/Games/Marcos/TruthOrDare/truth_or_dare
open ios/Runner.xcworkspace
```

⚠️ **IMPORTANT:** Always open `.xcworkspace`, NOT `.xcodeproj`

#### 3.2 Configure Signing in Xcode

1. Select **Runner** in the project navigator (left sidebar)
2. Select **Runner** under TARGETS
3. Click **Signing & Capabilities** tab
4. Configure the following:

**For Debug and Profile:**
- ✅ Check "Automatically manage signing"
- Team: Select your development team (BJC5J6L379)
- Bundle Identifier: `com.cuberix.truthordare` (already set)

**For Release:**
- ✅ Check "Automatically manage signing"
- Team: Select your development team (BJC5J6L379)
- Bundle Identifier: `com.cuberix.truthordare` (already set)

Xcode will automatically:
- Create signing certificates
- Generate provisioning profiles
- Register your App ID with Apple

#### 3.3 Verify Capabilities

In **Signing & Capabilities** tab, verify these are configured:

- ✅ **In-App Purchase** - Required (you're using in_app_purchase package)
- ⚠️ **App Tracking Transparency** - Check if needed for ads

#### 3.4 Add Missing Privacy Descriptions (if needed)

Your `Info.plist` should include:
- ✅ NSUserTrackingUsageDescription - Already added

If you use other features later, you may need to add:
- NSCameraUsageDescription (if adding camera features)
- NSPhotoLibraryUsageDescription (if allowing photo uploads)

---

### Phase 4: Build and Test

#### 4.1 Clean Build

```bash
# Clean Flutter build cache
flutter clean

# Get dependencies
flutter pub get

# Clean iOS build
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

#### 4.2 Run on Physical Device

```bash
# Connect your iPhone via USB
# Trust the device when prompted

# Run in release mode
flutter run --release
```

**Test thoroughly:**
- [ ] All game modes work
- [ ] Player addition/removal
- [ ] Scoring system
- [ ] Custom challenges
- [ ] Navigation flows
- [ ] Ads display correctly (if applicable)
- [ ] In-app purchases work (test in sandbox)

#### 4.3 Build for Release

```bash
# Build iOS app in release mode
flutter build ios --release

# This creates an archive you'll use for submission
```

---

### Phase 5: App Store Connect Setup

#### 5.1 Create App Listing

1. Go to https://appstoreconnect.apple.com
2. Click **"Apps"** → **"+"** → **"New App"**
3. Fill in the form:
   - **Platform:** iOS
   - **Name:** Truth or Dare: Party Game
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** Select `com.cuberix.truthordare`
   - **SKU:** truthordare_ios_2024 (unique identifier for your records)
   - **User Access:** Full Access

#### 5.2 Complete App Information

In App Store Connect, navigate to your app and fill in:

**1. Pricing and Availability**
- Price: Free (with in-app purchases)
- Availability: All territories (or select specific countries)

**2. App Privacy**
- Click **"Get Started"**
- Answer privacy questionnaire based on your data collection
- Since you use AdMob: You likely collect "Device ID" and "Product Interaction"

**3. App Information**
- Category: Games
- Content Rights: Check if you own all rights
- Age Rating: Complete questionnaire
- Age Rating will likely be: 12+ or 17+ due to adult content

**4. Version Information**
- Screenshots: Upload for required device sizes
- Promotional Text: (paste from above)
- Description: (paste from above)
- Keywords: (paste from above)
- Support URL: Your support page
- Marketing URL: (optional)

**5. Rating**
- Complete the questionnaire honestly
- Questions about violence, profanity, sexual content, etc.
- Expected rating: 12+ or 17+

---

### Phase 6: Upload Build with Xcode

#### 6.1 Archive in Xcode

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select **"Any iOS Device (arm64)"** as destination (NOT a simulator)
3. Go to **Product** → **Archive**
4. Wait for archive to complete (2-10 minutes)

#### 6.2 Upload to App Store Connect

1. When archive completes, the **Organizer** window opens
2. Select your archive
3. Click **"Distribute App"**
4. Select **"App Store Connect"**
5. Click **"Upload"**
6. Choose:
   - Upload your app's symbols: ✅ YES
   - Manage version and build number: Xcode Managed
7. Review signing certificate and profile
8. Click **"Upload"**
9. Wait for upload (5-20 minutes)

#### 6.3 Alternative: Upload with Command Line

```bash
# Build archive
flutter build ipa --release

# Upload using Transporter app (download from App Store)
# Or use command line:
xcrun altool --upload-app --type ios \
  --file build/ios/ipa/*.ipa \
  --username "your-apple-id@email.com" \
  --password "app-specific-password"
```

To create app-specific password:
1. Go to https://appleid.apple.com
2. Sign in
3. Security → App-Specific Passwords
4. Generate new password

---

### Phase 7: Submit for Review

#### 7.1 Wait for Build Processing

- After upload, build needs to process (10-60 minutes)
- You'll receive email when processing completes
- Check status in App Store Connect → TestFlight → Builds

#### 7.2 Select Build

1. In App Store Connect, go to your app
2. Go to **"App Store"** tab
3. Click on version **"1.0.1"**
4. Scroll to **"Build"** section
5. Click **"+"** and select your processed build

#### 7.3 Complete Review Information

**App Review Information:**
- First Name, Last Name, Phone, Email
- Notes: (Explain the different modes and age ratings if needed)

**Demo Account (if needed):**
- Not required for your app

**Contact Information:**
- Phone: Your contact phone
- Email: Your support email

**Notes for Review:**
```
This app contains four game modes with different age-appropriate content:
- Kids Mode: Ages 7-12
- Teens Mode: Ages 13-17
- Adult Mode: 18+
- Couples Mode: 18+

The app requires no login and works completely offline. All challenges are pre-loaded, and users can add custom challenges that are stored locally.

To test:
1. Launch app
2. Select any game mode
3. Add 2+ players
4. Play a few rounds to see challenges

Please note: The app contains ads and in-app purchases to remove ads.
```

**Advertising Identifier (IDFA):**
- Does this app use the Advertising Identifier (IDFA)? **YES** (because of AdMob)
- Check: "Serve advertisements within the app"
- Check: "Attribute an action taken within this app to a previously served advertisement"

#### 7.4 Submit for Review

1. Click **"Add for Review"** (top right)
2. Review all information
3. Click **"Submit to App Review"**
4. Confirm submission

---

### Phase 8: Review Process

#### 8.1 Review Timeline

- **In Review:** 1-3 days (typically 24-48 hours)
- **Status:** Check App Store Connect for updates
- **Email Notifications:** You'll receive emails for status changes

#### 8.2 Possible Outcomes

**✅ Approved:**
- Your app is live on the App Store!
- Appears within 24 hours
- You can control release date in App Store Connect

**⚠️ Metadata Rejected:**
- Usually screenshots or description issues
- Fix and resubmit (no new build needed)
- Quick turnaround (few hours)

**❌ Binary Rejected:**
- Code issues or guideline violations
- Must fix code and upload new build
- Common reasons:
  - Crashes
  - Missing privacy policy
  - Age-inappropriate content not gated
  - Ads in kids mode (violation)

#### 8.3 If Rejected

1. Read rejection reason carefully
2. Fix issues in code or metadata
3. Respond in Resolution Center if clarification needed
4. Upload new build (if code changes)
5. Resubmit for review

---

## 🚨 Common Issues & Solutions

### Issue 1: "No Signing Certificate Found"

**Solution:**
```bash
# In Xcode, go to:
# Preferences → Accounts → Select Apple ID → Download Manual Profiles
# Then: Signing & Capabilities → Check "Automatically manage signing"
```

### Issue 2: "Archive Failed"

**Solution:**
```bash
# Clean everything
flutter clean
cd ios
pod deintegrate
pod install
cd ..

# In Xcode:
# Product → Clean Build Folder (Shift + Cmd + K)
# Then try archiving again
```

### Issue 3: "Missing Compliance"

After first build uploads, you'll see "Missing Compliance" warning.

**Solution:**
1. Click on build in TestFlight
2. Click "Provide Export Compliance Information"
3. Answer: "Does your app use encryption?" → NO (unless you added custom encryption)
4. Submit

### Issue 4: "Invalid Bundle ID"

**Solution:**
- Ensure Bundle ID in Xcode matches the one in App Store Connect
- Check: Runner → Target → Signing & Capabilities
- Should be: `com.cuberix.truthordare`

### Issue 5: "Upload Failed - Asset Validation"

**Solution:**
- Check Info.plist has all required keys
- Verify app icon is 1024x1024 without alpha channel
- Run: `flutter build ios --release` again

---

## 📝 Pre-Submission Checklist

Before submitting, verify:

### Technical:
- [ ] App builds successfully in release mode
- [ ] Tested on physical iOS device
- [ ] No crashes or major bugs
- [ ] All game modes work correctly
- [ ] Ads display properly (if applicable)
- [ ] In-app purchases tested in sandbox
- [ ] App icon is correct and visible
- [ ] Launch screen displays properly
- [ ] App name displays correctly
- [ ] Version number is correct (1.0.1)

### Content:
- [ ] Screenshots prepared (required sizes)
- [ ] App description written and reviewed
- [ ] Keywords selected
- [ ] Privacy policy created and accessible online
- [ ] Support URL is live and functional
- [ ] Age rating questionnaire completed honestly
- [ ] All content is age-appropriate for selected rating

### Legal:
- [ ] You own rights to all content
- [ ] Privacy policy complies with Apple requirements
- [ ] COPPA compliance (if targeting kids)
- [ ] Terms of service (if applicable)
- [ ] Copyright notices (if using third-party content)

### App Store Connect:
- [ ] App listing created
- [ ] Pricing set to Free
- [ ] In-app purchases configured (if applicable)
- [ ] Build uploaded and processed
- [ ] Build selected for version 1.0.1
- [ ] Review information completed
- [ ] Contact information accurate

---

## 🎯 Quick Command Reference

```bash
# Clean project
flutter clean && cd ios && pod install && cd ..

# Run on device
flutter run --release

# Build for release
flutter build ios --release

# Build IPA
flutter build ipa --release

# Open Xcode workspace
open ios/Runner.xcworkspace

# Open iOS simulator
open -a Simulator

# Check Flutter doctor
flutter doctor -v
```

---

## 📱 Post-Launch Tasks

After approval:

1. **Monitor Crashes:**
   - Use App Store Connect → Analytics → Crashes
   - Fix critical issues immediately

2. **Respond to Reviews:**
   - Reply to user reviews in App Store Connect
   - Address concerns professionally

3. **Track Performance:**
   - Downloads
   - In-app purchase conversion
   - User retention
   - Crash-free sessions

4. **Plan Updates:**
   - Fix bugs reported by users
   - Add new features
   - Increment version number for updates (1.0.2, 1.1.0, etc.)

---

## 🆘 Need Help?

**Apple Developer Support:**
- https://developer.apple.com/contact/
- Phone: 1-800-633-2152 (US)

**App Store Connect Support:**
- https://developer.apple.com/contact/app-store/

**Flutter iOS Deployment:**
- https://docs.flutter.dev/deployment/ios

**Common Rejection Reasons:**
- https://developer.apple.com/app-store/review/guidelines/

---

## 🎉 Success!

Once your app is approved and live:

1. Share the App Store link:
   ```
   https://apps.apple.com/app/idXXXXXXXXX
   ```

2. Celebrate! 🎊 You've successfully published an iOS app!

3. Start planning your next update with new features and improvements.

---

**Good luck with your submission! 🚀**

*Last Updated: November 21, 2025*


