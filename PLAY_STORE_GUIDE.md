# Complete Google Play Store Submission Guide

This guide walks you through the entire process of preparing and submitting FuliTrack to the Google Play Store.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Create Signing Keystore](#step-1-create-signing-keystore)
3. [Step 2: Configure Signing](#step-2-configure-signing)
4. [Step 3: Build Release Version](#step-3-build-release-version)
5. [Step 4: Test Release Build](#step-4-test-release-build)
6. [Step 5: Create Google Play Console Account](#step-5-create-google-play-console-account)
7. [Step 6: Create App in Play Console](#step-6-create-app-in-play-console)
8. [Step 7: Prepare Store Listing](#step-7-prepare-store-listing)
9. [Step 8: Set Up App Content](#step-8-set-up-app-content)
10. [Step 9: Upload Release](#step-9-upload-release)
11. [Step 10: Submit for Review](#step-10-submit-for-review)
12. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have:

- ✅ Updated package name (done: `com.fulitrack.app`)
- ✅ Configured build system (done: ProGuard, signing config)
- ✅ Build scripts ready (done: build-aab.sh, build-apk.sh)
- ⬜ Google Play Developer account ($25 one-time fee)
- ⬜ Privacy policy URL (see PRIVACY_POLICY_TEMPLATE.md)
- ⬜ Play Store assets (see PLAY_STORE_ASSETS.md)

---

## Step 1: Create Signing Keystore

The keystore is used to sign your app. **CRITICAL**: Keep this file and passwords safe! If you lose it, you can never update your app again.

### 1.1 Generate Keystore

```bash
# Navigate to a secure location (NOT your project directory!)
cd ~/Documents/keystore

# Generate keystore
keytool -genkey -v -keystore fulitrack-release-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias fulitrack

# You'll be prompted for:
# - Keystore password (create a strong password)
# - Key password (can be same as keystore password)
# - Your name
# - Organization name
# - City/Locality
# - State/Province
# - Country code (KE for Kenya)
```

### 1.2 Secure Your Keystore

**IMPORTANT**:
- ✅ Backup keystore file to multiple secure locations (cloud storage, external drive)
- ✅ Save passwords in a password manager
- ✅ NEVER commit keystore to version control (.gitignore already configured)
- ✅ Consider using Android's Play App Signing for additional security

### 1.3 Keystore Information Template

Save this information securely:

```
Keystore Location: ~/Documents/keystore/fulitrack-release-key.jks
Keystore Password: [YOUR_PASSWORD]
Key Alias: fulitrack
Key Password: [YOUR_KEY_PASSWORD]
Created: [DATE]
Validity: 10000 days (until [EXPIRY_DATE])
```

---

## Step 2: Configure Signing

### 2.1 Create key.properties

```bash
cd /path/to/FuliTrack
cp android/key.properties.template android/key.properties
```

### 2.2 Edit key.properties

Open `android/key.properties` and fill in:

```properties
storePassword=YOUR_ACTUAL_KEYSTORE_PASSWORD
keyPassword=YOUR_ACTUAL_KEY_PASSWORD
keyAlias=fulitrack
storeFile=/home/yourusername/Documents/keystore/fulitrack-release-key.jks
```

**Replace**:
- `YOUR_ACTUAL_KEYSTORE_PASSWORD` with your keystore password
- `YOUR_ACTUAL_KEY_PASSWORD` with your key password
- `/home/yourusername/...` with actual path to your keystore

### 2.3 Verify Configuration

The build system is already configured to:
- ✅ Load key.properties automatically
- ✅ Apply release signing
- ✅ Enable ProGuard/R8 obfuscation
- ✅ Optimize and shrink resources

---

## Step 3: Build Release Version

### Option A: Interactive Build (Recommended)

```bash
./build-release.sh
```

Follow the prompts to choose:
1. Android App Bundle (AAB) - for Play Store
2. APK - for testing
3. Both

### Option B: Quick AAB Build

```bash
./build-aab.sh
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Option C: Quick APK Build

```bash
./build-apk.sh
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Option D: Manual Build

```bash
# Clean
flutter clean

# Get dependencies
flutter pub get

# Build AAB for Play Store
flutter build appbundle --release

# Or build APK for testing
flutter build apk --release
```

---

## Step 4: Test Release Build

**CRITICAL**: Always test the release build before submitting!

### 4.1 Install on Physical Device

```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use bundletool for AAB testing
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=fulitrack.apks \
  --ks=~/Documents/keystore/fulitrack-release-key.jks \
  --ks-key-alias=fulitrack

bundletool install-apks --apks=fulitrack.apks
```

### 4.2 Testing Checklist

Test all critical functionality:

- [ ] App launches successfully
- [ ] SMS permission request works
- [ ] SMS messages are parsed correctly (Fuliza messages)
- [ ] Loan data is displayed properly
- [ ] Charts/analytics render correctly
- [ ] Notifications work (schedule, display, click)
- [ ] Settings are saved and loaded
- [ ] App doesn't crash on rotation/background
- [ ] Dark mode works (if implemented)
- [ ] Privacy settings (opt-in analytics) work
- [ ] No debug logs or test data visible

### 4.3 Performance Testing

- [ ] App size is reasonable (check AAB/APK size)
- [ ] Launch time is fast
- [ ] UI is smooth (60fps)
- [ ] Memory usage is normal
- [ ] Battery drain is minimal

### 4.4 Check for Issues

Common release build issues:
- Missing assets (check ProGuard rules)
- Crashes due to obfuscation
- Missing permissions in manifest
- Hardcoded values or test credentials

---

## Step 5: Create Google Play Console Account

### 5.1 Sign Up

1. Go to [Google Play Console](https://play.google.com/console)
2. Sign in with your Google account
3. Pay the $25 one-time developer registration fee
4. Complete your account details:
   - Developer name
   - Contact email
   - Website (optional)
   - Phone number

### 5.2 Account Verification

- May take 24-48 hours for approval
- You'll receive email confirmation
- Set up payment profile for app sales (if paid app)

---

## Step 6: Create App in Play Console

### 6.1 Create New App

1. Click **Create app**
2. Fill in details:
   - **App name**: FuliTrack
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free
3. Accept Developer Program Policies and US export laws
4. Click **Create app**

### 6.2 Initial Setup Tasks

Complete the dashboard checklist:
- Set up app
- Store listing
- App content
- Release

---

## Step 7: Prepare Store Listing

### 7.1 App Details

Navigate to: **Main store listing**

**App name**:
```
FuliTrack - Fuliza Loan Tracker
```

**Short description** (80 characters max):
```
Privacy-first Fuliza M-PESA loan tracker. Track loans locally, no cloud.
```

**Full description** (4000 characters max):
See `PLAY_STORE_ASSETS.md` for full template

### 7.2 Upload Graphics

Upload required assets (see PLAY_STORE_ASSETS.md for specs):

1. **App icon** (512 x 512):
   - Upload your high-res icon
   - Must be PNG, 32-bit with alpha

2. **Feature graphic** (1024 x 500):
   - Create eye-catching banner
   - Highlight app name and key benefit

3. **Screenshots** (at least 2, max 8):
   - Phone: 1080 x 1920 (portrait) or 1920 x 1080 (landscape)
   - Show key features: dashboard, charts, settings

4. **Promo video** (optional):
   - YouTube link
   - 30 seconds - 2 minutes

### 7.3 Categorization

- **App category**: Finance
- **Tags**: fuliza, mpesa, loan, kenya, finance, tracker
- **Contact details**:
  - Email: your-support-email@example.com
  - Website: (optional)
  - Phone: (optional)

---

## Step 8: Set Up App Content

### 8.1 Privacy Policy

**REQUIRED** - SMS permission requires privacy policy

1. Navigate to: **App content** → **Privacy policy**
2. Enter your privacy policy URL
   - Must be publicly accessible
   - Must explain SMS usage
   - See PRIVACY_POLICY_TEMPLATE.md for template

Example hosting:
- GitHub Pages: `https://yourusername.github.io/fulitrack/privacy-policy`
- Your website: `https://yourwebsite.com/privacy`

### 8.2 App Access

Navigate to: **App content** → **App access**

- **Special access required**: No (app doesn't require login)
- **All features available without restrictions**: Yes

### 8.3 Ads

Navigate to: **App content** → **Ads**

- **Contains ads**: No
- FuliTrack is completely ad-free ✅

### 8.4 Content Rating

Navigate to: **App content** → **Content rating**

1. Click **Start questionnaire**
2. Select category: **Utility, Productivity, Communication or Other**
3. Answer questions:
   - Violence: No
   - Sexual content: No
   - Profanity: No
   - Controlled substances: No
   - User-generated content: No
   - Realistic gambling: No
   - Digital purchases: No
   - Location sharing: No
   - Personal info: **Yes** (SMS access)
4. Submit for rating

Expected rating: **E (Everyone)** or **PEGI 3**

### 8.5 Target Audience

Navigate to: **App content** → **Target audience**

- **Target age group**: 18+ (financial app)
- **Appeal to children**: No

### 8.6 Data Safety

Navigate to: **App content** → **Data safety**

This is CRITICAL for SMS permissions!

**Data collection**:
- **Personal information**: Yes
  - User messages: SMS data
  - Purpose: App functionality (Fuliza loan tracking)
  - Data is NOT shared with third parties
  - Data is stored on device only
  - Users can request deletion (by clearing app data)

**Security practices**:
- Data is encrypted in transit: No (no internet connection)
- Data is encrypted at rest: Yes (device encryption)
- Users can request data deletion: Yes
- Data is only used for app functionality: Yes

Example form completion:
```
Does your app collect or share any user data?
→ Yes

What type of data?
→ Messages (SMS or MMS)

How is this data used?
→ App functionality (required for core features)

Is this data shared with third parties?
→ No

Can users choose whether this data is collected?
→ No (required for app functionality)

Is this data encrypted in transit?
→ N/A (no network transmission)

Can users request data deletion?
→ Yes
```

---

## Step 9: Upload Release

### 9.1 Create Production Release

1. Navigate to: **Production** → **Create new release**
2. Choose **Google Play App Signing** (recommended)
   - Upload your app signing key
   - Google manages the key for you
   - Enables key upgrade in future

### 9.2 Upload App Bundle

1. Click **Upload**
2. Select your AAB file:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```
3. Wait for upload and processing
4. Review any warnings or errors

### 9.3 Release Name

```
Version 1.0.0 - Initial Release
```

### 9.4 Release Notes

Write clear release notes (max 500 characters per language):

**English**:
```
🎉 Initial release of FuliTrack!

Features:
✅ Track Fuliza loans privately on your device
✅ Automatic SMS parsing for loan detection
✅ Visual analytics and charts
✅ Payment deadline notifications
✅ 100% local storage - no cloud, complete privacy

Thank you for trying FuliTrack! Please rate and review if you find it helpful.
```

### 9.5 Review Release

1. Check all information is correct
2. Review app bundle details:
   - Version code: 1
   - Version name: 1.0.0
   - Supported devices/configurations
3. Review warnings (if any)

---

## Step 10: Submit for Review

### 10.1 Pre-Submission Checklist

Complete checklist before submitting:

**App Content** (all must be ✅):
- [x] Privacy policy
- [x] App access
- [x] Ads declaration
- [x] Content rating
- [x] Target audience
- [x] Data safety

**Store Listing** (all must be ✅):
- [x] App name
- [x] Short description
- [x] Full description
- [x] App icon
- [x] Feature graphic
- [x] Screenshots (at least 2)
- [x] Categorization

**Release** (all must be ✅):
- [x] App bundle uploaded
- [x] Release name
- [x] Release notes
- [x] No critical warnings

### 10.2 Start Rollout

1. Click **Review release**
2. Review all sections one final time
3. Check for any errors or warnings
4. Click **Start rollout to Production**
5. Confirm rollout

### 10.3 Review Process

**Timeline**:
- Initial review: Usually 1-7 days
- May request additional information
- Check email and Play Console notifications regularly

**What Google Reviews**:
- App functionality
- Policy compliance
- Permissions usage justification
- Content rating accuracy
- Data safety declarations

**Possible Outcomes**:
- ✅ **Approved**: App goes live on Play Store
- ⚠️ **Changes Requested**: Fix issues and resubmit
- ❌ **Rejected**: Address violations and resubmit

---

## Step 11: After Approval

### 11.1 App is Live!

Once approved:
- App appears on Play Store within hours
- Users can search and download
- Play Store URL: `https://play.google.com/store/apps/details?id=com.fulitrack.app`

### 11.2 Monitor Performance

Use Play Console to track:
- Installs and uninstalls
- Ratings and reviews
- Crash reports (if any)
- User feedback
- Statistics and analytics

### 11.3 Respond to Reviews

- Thank users for positive reviews
- Address issues in negative reviews
- Use feedback to improve app

### 11.4 Update App

For future updates:
1. Increment version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version name + build number
   ```
2. Build new AAB
3. Upload to Play Console
4. Write release notes
5. Submit for review

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "App not signed properly"
**Solution**:
- Verify key.properties has correct paths and passwords
- Ensure keystore file exists and is readable
- Check signing config in build.gradle.kts

#### Issue: "Version code must be higher than previous"
**Solution**:
- Increment build number in pubspec.yaml
- Version format: `X.Y.Z+BUILD` (e.g., `1.0.0+2`)

#### Issue: "Permissions not properly declared"
**Solution**:
- Ensure all permissions are in AndroidManifest.xml
- Justify sensitive permissions in Data Safety section
- Update privacy policy to explain permissions

#### Issue: "App crashes on release but not debug"
**Solution**:
- Check ProGuard rules (proguard-rules.pro)
- Test release build thoroughly
- Review crash logs in Play Console

#### Issue: "Missing privacy policy"
**Solution**:
- Create privacy policy using PRIVACY_POLICY_TEMPLATE.md
- Host on publicly accessible URL
- Add URL to Play Console

#### Issue: "SMS permission requires declaration"
**Solution**:
- Complete Data Safety section thoroughly
- Explain SMS usage in privacy policy
- Justify in app description

#### Issue: "Feature graphic rejected"
**Solution**:
- Ensure exactly 1024 x 500 pixels
- No device frames or screenshots
- No low-quality or blurry images
- Meet content policy guidelines

---

## Security Best Practices

### Keystore Security
- ✅ Store keystore in secure location (not project directory)
- ✅ Backup to multiple locations (encrypted cloud, external drive)
- ✅ Use strong passwords (20+ characters, password manager)
- ✅ Never commit to version control
- ✅ Consider using Play App Signing

### Code Security
- ✅ ProGuard/R8 obfuscation enabled
- ✅ No hardcoded credentials or API keys
- ✅ Validate all user input
- ✅ Use HTTPS for any network calls
- ✅ Follow OWASP mobile security guidelines

---

## Testing Best Practices

### Internal Testing Track
Before production release, consider using Internal Testing:
1. Create internal testing release
2. Add test users (up to 100 emails)
3. Get feedback before public release
4. No review process for internal testing

### Closed Testing Track
For beta testing:
1. Create closed testing release
2. Share opt-in link with testers
3. Gather feedback and crash reports
4. Iterate before production

### Open Testing Track
Public beta:
1. Anyone can join
2. Limited to 20,000 testers
3. Great for finding edge cases
4. Users can provide feedback

---

## Additional Resources

### Official Documentation
- [Google Play Console](https://play.google.com/console)
- [Android Developers - Publish](https://developer.android.com/studio/publish)
- [Play Console Help Center](https://support.google.com/googleplay/android-developer/)

### Flutter Resources
- [Flutter - Build and release Android app](https://flutter.dev/docs/deployment/android)
- [Flutter - Obfuscating Dart code](https://flutter.dev/docs/deployment/obfuscate)

### Useful Tools
- [bundletool](https://github.com/google/bundletool) - Test AAB locally
- [Google Play Console API](https://developers.google.com/android-publisher) - Automate publishing

---

## Quick Reference Commands

```bash
# Generate keystore
keytool -genkey -v -keystore ~/fulitrack-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias fulitrack

# Build AAB
./build-aab.sh
# or
flutter build appbundle --release

# Build APK
./build-apk.sh
# or
flutter build apk --release

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Check AAB contents
bundletool dump manifest --bundle=build/app/outputs/bundle/release/app-release.aab
```

---

## Support

For issues specific to FuliTrack:
- Check TROUBLESHOOTING.md
- Review build logs
- Test on physical device

For Play Console issues:
- [Play Console Help](https://support.google.com/googleplay/android-developer/)
- [Developer Policy Center](https://play.google.com/about/developer-content-policy/)

---

**Good luck with your Play Store submission! 🚀**

Remember: The first submission always takes the longest. Future updates will be much faster.
