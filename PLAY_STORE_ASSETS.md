# Google Play Store Assets Requirements

This document outlines all the assets and materials you need to prepare for submitting FuliTrack to the Google Play Store.

## 📱 App Screenshots

### Required Specifications
- **Minimum**: 2 screenshots
- **Maximum**: 8 screenshots
- **Format**: PNG or JPG (24-bit, no alpha)
- **Dimensions**:
  - Phone: 320px - 3840px on each side
  - Recommended: 1080 x 1920 px (portrait) or 1920 x 1080 px (landscape)

### What to Capture
1. **Home Dashboard** - Show Fuliza loan summary and overview
2. **Transaction History** - Display list of loans with dates and amounts
3. **Analytics/Charts** - Show the visual charts/graphs feature
4. **Notifications Settings** - Display notification management
5. **Privacy Settings** - Show opt-in analytics and privacy controls
6. **Empty State** - (Optional) Show friendly empty state for new users

### Best Practices
- Use actual app content, not placeholder data
- Ensure text is readable (minimum 12sp font size)
- Remove any personal/sensitive information
- Show the app in action, not just static screens
- Use consistent device frames (optional but professional)

---

## 🎨 App Icon

### High-Resolution Icon
- **Size**: 512 x 512 px
- **Format**: 32-bit PNG with alpha
- **Purpose**: Displayed on Play Store listing

### Specifications
- Must be exactly 512 x 512 pixels
- Must be PNG format
- Should match your launcher icon design
- No rounded corners (Google handles this automatically)
- Safe area: Keep important content within central 80%

**Current Icon**: `assets/images/app_icon.png`
- ✅ Make sure this is high quality at 512x512

---

## 🖼️ Feature Graphic

### Required Specifications
- **Size**: 1024 x 500 px (exactly)
- **Format**: PNG or JPG (no alpha)
- **Purpose**: Displayed at top of Play Store listing

### Design Guidelines
- Feature your app name and key benefit
- Use eye-catching design but keep it simple
- Don't include device frames or screenshots
- Ensure text is large and readable
- Match your app's color scheme/branding

### Suggested Content
```
[ FuliTrack Logo ]
Track Your Fuliza Loans Privately & Easily
```

Or:

```
Your Personal Fuliza Loan Manager
Never Miss a Payment Deadline
```

---

## 📝 Text Content

### Short Description
- **Length**: Up to 80 characters
- **Purpose**: Brief tagline shown in search results

**Example**:
```
Privacy-first Fuliza M-PESA loan tracker for Kenya. Track loans locally.
```

### Full Description
- **Length**: Up to 4000 characters
- **Purpose**: Full app description on Play Store listing

**Template**:
```
FuliTrack - Your Privacy-First Fuliza Loan Manager

Never miss a Fuliza loan payment again! FuliTrack helps you track your Fuliza M-PESA
loans with complete privacy. All your data stays on your device - no cloud storage,
no external servers, no data sharing.

KEY FEATURES:
• 📊 Loan Dashboard - See all your Fuliza loans at a glance
• 📱 SMS Parsing - Automatically reads Fuliza SMS (with your permission)
• 📈 Visual Analytics - Charts showing your loan patterns over time
• 🔔 Smart Notifications - Reminders before repayment deadlines
• 🔒 100% Private - All data stored locally on your device
• 💚 No Ads - Clean, distraction-free experience
• 🇰🇪 Made for Kenya - Designed specifically for Fuliza users

HOW IT WORKS:
1. Grant SMS permission (one-time)
2. FuliTrack automatically detects Fuliza messages
3. View your loans organized by date and status
4. Get notifications before deadlines
5. Track your repayment history with charts

PRIVACY FIRST:
• No account creation required
• No internet connection needed
• No data ever leaves your phone
• Optional analytics (completely opt-in)
• No collection of sensitive financial data

PERMISSIONS:
• SMS Read: To detect Fuliza loan messages from M-PESA
• Notifications: To remind you of upcoming deadlines
• Storage: To save your loan data locally

Perfect for Kenyans who want to stay on top of their Fuliza loans without
compromising privacy. Download FuliTrack today and take control of your loans!

Note: FuliTrack is not affiliated with Safaricom or M-PESA. This is an independent
tool created to help Fuliza users manage their loans.
```

---

## 🎥 Promotional Video (Optional but Recommended)

### Specifications
- **Length**: 30 seconds - 2 minutes
- **Format**: YouTube link
- **Purpose**: Shows app in action

### Content Ideas
1. Quick app tour (15-20 seconds)
2. Show SMS permission flow (10 seconds)
3. Demonstrate loan tracking (15 seconds)
4. Show charts/analytics (10 seconds)
5. Call-to-action (5 seconds)

---

## 📋 Content Rating Questionnaire

You'll need to complete Google's content rating questionnaire. Here's what to expect for FuliTrack:

- **Violence**: None
- **Sexual Content**: None
- **Profanity**: None
- **Controlled Substances**: None
- **Gambling**: None
- **User Interaction**: No (app doesn't allow user-to-user communication)
- **Personal Info**: Yes (app accesses SMS)
- **Location Sharing**: No

**Expected Rating**: E (Everyone) or PEGI 3

---

## 🔐 Privacy Policy (REQUIRED!)

**⚠️ CRITICAL**: Apps that request sensitive permissions (like SMS) MUST have a privacy policy.

### Requirements
- Must be hosted on a publicly accessible URL
- Must explain what data is collected and why
- Must explain SMS permission usage
- Must be written in clear language

### Hosting Options
1. GitHub Pages (free, easy)
2. Your own website
3. Privacy policy generators (ensure they're comprehensive)

### Must Include for FuliTrack
- Why SMS permission is needed (Fuliza loan tracking)
- What SMS data is accessed (only Fuliza messages from M-PESA)
- How data is stored (locally on device)
- That no data is shared with third parties
- User rights (data deletion, access)
- Firebase Analytics opt-in (if using analytics)

**Example Privacy Policy Template**: See `PRIVACY_POLICY_TEMPLATE.md`

---

## 🎯 App Category & Tags

### Primary Category
- **Finance** or **Business**

### Secondary Category (Optional)
- **Tools** or **Productivity**

### Tags/Keywords (for ASO - App Store Optimization)
```
Fuliza, M-PESA, loan tracker, loan manager, Kenya,
Safaricom, debt tracker, payment reminder, finance app,
budget app, privacy, local storage, SMS parser
```

---

## 🌍 Localization

### Target Countries
- **Primary**: Kenya
- **Language**: English (consider adding Swahili in future updates)

### Additional Metadata to Localize
- App description (English + Swahili)
- Screenshots (consider adding Swahili UI screenshots)
- Short description

---

## ✅ Pre-Submission Checklist

Before uploading to Play Console, ensure you have:

- [ ] 2-8 high-quality screenshots (phone)
- [ ] 512x512 high-res app icon
- [ ] 1024x500 feature graphic
- [ ] Short description (≤80 chars)
- [ ] Full description (≤4000 chars)
- [ ] Privacy policy URL
- [ ] Content rating completed
- [ ] App category selected
- [ ] Target countries/languages set
- [ ] Release APK/AAB uploaded
- [ ] All required permissions explained

---

## 📦 Asset Checklist Summary

| Asset | Size | Format | Required | Status |
|-------|------|--------|----------|--------|
| Screenshots (Phone) | 1080x1920 | PNG/JPG | ✅ Yes | ⬜ To Do |
| High-Res Icon | 512x512 | PNG | ✅ Yes | ⚠️ Check Current |
| Feature Graphic | 1024x500 | PNG/JPG | ✅ Yes | ⬜ To Do |
| Short Description | ≤80 chars | Text | ✅ Yes | ⬜ To Do |
| Full Description | ≤4000 chars | Text | ✅ Yes | ⬜ To Do |
| Privacy Policy | N/A | URL | ✅ Yes | ⬜ To Do |
| Promo Video | 30s-2min | YouTube | ❌ Optional | ⬜ Skip/To Do |

---

## 🔧 Tools to Help Create Assets

### Screenshot Tools
- **Android Studio** - Built-in emulator screenshots
- **Scrcpy** - Screen mirror/record physical devices
- **Screenshot Framer** - Add device frames

### Graphic Design Tools
- **Canva** - Free templates for feature graphics
- **Figma** - Professional design tool (free tier)
- **GIMP** - Free Photoshop alternative
- **Photopea** - Online Photoshop-like editor

### Privacy Policy Generators
- **TermsFeed** - https://www.termsfeed.com/privacy-policy-generator/
- **FreePrivacyPolicy** - https://www.freeprivacypolicy.com/
- **GetTerms** - https://getterms.io/

---

## 📚 Additional Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [Play Store Asset Guidelines](https://developer.android.com/distribute/marketing-tools/device-art-generator)
- [Content Rating Guide](https://support.google.com/googleplay/android-developer/answer/9859655)

---

**Next Step**: After preparing these assets, see `PLAY_STORE_GUIDE.md` for the complete submission process.
