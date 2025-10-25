# Truth or Dare - Deployment Checklist

## ✅ Pre-Deployment Status

### Architecture

- [x] App is fully functional offline
- [x] Local data storage with Hive
- [x] Hardcoded challenges (requires app update to change)
- [ ] NO admin integration (no remote content management)
- [ ] NO backend API
- [ ] NO analytics tracking

### Clean-up Required Before Launch

#### 1. Remove Firebase Remnants

```bash
# Remove empty Firebase folder
rm -rf lib/services/firebase

# Remove Firebase iOS header
rm ios/Runner/FirebaseModuleFix.h
```

#### 2. Update iOS Project

- Remove FirebaseModuleFix.h from Xcode project
- Clean build folder

#### 3. Verify AdMob IDs

- [ ] **CRITICAL**: Replace test AdMob IDs with production IDs
  - Android: `android/app/src/main/AndroidManifest.xml` line 15
  - iOS: `ios/Runner/Info.plist` line 49

### Content Management

**Current State:**

- All challenges are in: `lib/data/datasources/preloaded_challenges.dart`
- Total challenges: ~400+ across 4 game modes
- To update content: Must release new app version

**Content Verification:**

- [ ] Review all Kids mode challenges (appropriate for ages 7-12)
- [ ] Review all Teens mode challenges (appropriate for ages 13-17)
- [ ] Review all Adult mode challenges (18+ content warning)
- [ ] Review all Couples mode challenges

### Testing Checklist

- [ ] Test all 4 game modes
- [ ] Test with 2 players (minimum)
- [ ] Test with 10+ players
- [ ] Test custom challenge creation
- [ ] Test offline functionality
- [ ] Test AdMob ads display correctly
- [ ] Test rewarded ads for extra games
- [ ] Test in-app purchase (if implemented)

### App Store Requirements

#### Android (Google Play)

- [x] Package: `com.cuberix.truthordare`
- [x] AAB signed and ready
- [ ] Upload screenshots
- [ ] Complete store listing
- [ ] Privacy policy (required for ads)
- [ ] Content rating (set to Teen/Mature based on content)

#### iOS (App Store)

- [x] Bundle ID: `com.cuberix.truthordare`
- [x] iOS build ready
- [ ] Archive in Xcode
- [ ] Upload to App Store Connect
- [ ] Screenshots for all required sizes
- [ ] Privacy policy
- [ ] Age rating (12+ or 17+ based on content)

### Post-Launch Monitoring

**Without Admin Integration, Monitor Via:**

- App Store reviews
- Crash reports
- User feedback
- Download/usage analytics from stores

**Limitations:**

- Cannot update challenges remotely
- Cannot A/B test content
- Cannot track which challenges are popular
- Cannot customize per region/user

## 🔮 Future Enhancements (Optional)

### Phase 2: Add Admin Integration

1. **Firebase Firestore** for challenge storage
2. **Remote Config** for app settings
3. **Analytics** for usage tracking
4. **Admin Web Dashboard** for content management

**Benefits:**

- Update content without app store review
- Track popular challenges
- A/B test new content
- Regional customization
- Real-time content moderation

**Costs:**

- Firebase free tier: Up to 50K daily reads (sufficient for moderate usage)
- Development time: ~2-3 weeks
- Backend maintenance

## 📝 Decision Required

**Question for Stakeholder:**

Do you want to:

**A) Launch V1.0 without admin integration** (Faster, simpler, privacy-focused)

- ✅ Ready to deploy now
- ✅ No backend costs
- ⚠️ Content updates require app store submission
- ⚠️ No usage analytics

**B) Add admin integration before launch** (+2-3 weeks development)

- ✅ Remote content management
- ✅ Analytics and insights
- ✅ A/B testing capabilities
- ⚠️ Delays launch
- ⚠️ Backend costs and maintenance

**Recommendation:** Launch V1.0 as-is, add admin features in V1.1 based on user feedback.

---

## 🚨 Critical Issues to Address

### 1. **Firebase Cleanup**

Status: ⚠️ Must be done before launch

- Empty folders confuse developers
- iOS header may cause build issues

### 2. **AdMob Production IDs**

Status: 🔴 CRITICAL - Must be changed before launch

- Currently using test IDs
- Will not generate revenue with test IDs
- May violate AdMob policies

### 3. **Privacy Policy**

Status: 🔴 REQUIRED for app store approval

- Both stores require privacy policy for apps with ads
- Must explain data collection (AdMob collects user data)
- Link must be provided in store listing

### 4. **Content Review**

Status: ⚠️ Recommended

- Ensure all challenges are appropriate for target age groups
- Check for any offensive/inappropriate content
- Verify content adheres to app store guidelines

---

## ✅ Ready to Deploy Checklist

- [ ] Clean up Firebase remnants
- [ ] Replace test AdMob IDs with production IDs
- [ ] Create and publish privacy policy
- [ ] Review all challenge content
- [ ] Test on physical devices (iOS + Android)
- [ ] Prepare app store screenshots
- [ ] Write store descriptions
- [ ] Set age ratings correctly
- [ ] Upload builds to stores
- [ ] Submit for review

---

**Last Updated:** October 3, 2025
**App Version:** 1.0.0 (1)
**Build Status:** Ready (pending cleanup)







