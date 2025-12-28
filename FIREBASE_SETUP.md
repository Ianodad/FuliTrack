# Firebase Analytics Setup for FuliTrack

This guide explains how to set up Firebase Analytics with privacy-focused configuration.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `FuliTrack`
4. **Disable** Google Analytics for now (we'll configure it with privacy settings)
5. Click "Create Project"

## Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.fulitrack`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

## Step 3: Add iOS App (if needed)

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.example.fulitrack`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

## Step 4: Enable Analytics

1. In Firebase Console, go to Analytics → Dashboard
2. Click "Enable Google Analytics"
3. Select or create a Google Analytics account
4. **Important Privacy Settings:**
   - Disable "Google signals data collection"
   - Disable "Ads personalization"
   - Set data retention to minimum (2 months)

## Privacy Configuration

The app is pre-configured with these privacy settings:

### What IS Collected (when user opts in):
- Screen views (which screens are visited)
- Feature usage (which features are used)
- App crashes and errors
- General usage patterns

### What is NEVER Collected:
- Financial amounts or balances
- M-PESA transaction references
- Phone numbers or contacts
- SMS message content
- Device IDs or user IDs
- Personal information

### User Control:
- Analytics is **disabled by default**
- Users must explicitly opt-in via Settings → Privacy & Analytics
- Users can opt-out at any time

## File Locations

After setup, ensure these files exist:

```
android/app/google-services.json     # Android config
ios/Runner/GoogleService-Info.plist  # iOS config (if needed)
```

## Testing

1. Run the app: `flutter run`
2. Go to Settings → Privacy & Analytics
3. Enable "Help Improve FuliTrack"
4. Navigate through the app
5. Check Firebase Console → Analytics → Realtime

## Troubleshooting

If analytics events aren't appearing:
1. Ensure `google-services.json` is in the correct location
2. Check that the package name matches
3. Wait a few minutes for events to appear in the console
4. Check the app logs for any Firebase initialization errors

## GDPR/Privacy Compliance

This implementation follows privacy best practices:
- Opt-in only (not opt-out)
- No PII collection
- Clear user disclosure
- Easy opt-out mechanism
- Data minimization principle
