# 🎬 Animation Integration Guide

## Step 1: Get Your Animation Created

### Option A: Commission on Fiverr (Fastest)
1. Go to [Fiverr.com](https://fiverr.com)
2. Search: **"Lottie animation splash screen"**
3. Filter by:
   - ⭐ 4.8+ rating
   - 🏆 Top Rated sellers
   - 💰 Budget: $50-150
4. Send them:
   - `animation_brief.md` (in this folder)
   - `assets/images/app_icon.png`
5. Request delivery format: **Lottie JSON (.json)**

**Recommended sellers** (search these):
- "I will create lottie animation for app and website"
- "I will design lottie json animation for mobile app"

### Option B: Commission on LottieFiles
1. Go to [LottieFiles.com/hire](https://lottiefiles.com/hire)
2. Post your brief
3. Get quotes from animators
4. More expensive but higher quality

### Option C: Use Free Template (Quick Start)
1. Go to [LottieFiles.com](https://lottiefiles.com)
2. Search: "logo reveal" or "splash screen"
3. Download a similar animation
4. Customize colors in Lottie Editor (online)
5. Export as JSON

---

## Step 2: Receive Your Animation

You should receive:
1. ✅ `fulitrack_splash.json` - The Lottie animation file
2. ✅ `preview.mp4` - Video preview for approval
3. ⚠️ Source file (.aep) - Optional, for future edits

---

## Step 3: Add Animation to Project

### 3.1 Copy the file
```bash
# Place the JSON file here:
cp fulitrack_splash.json /home/user/FuliTrack/assets/animations/
```

### 3.2 Update splash_screen.dart
Open `lib/ui/screens/splash_screen.dart` and:

**REMOVE these lines** (around line 41-63):
```dart
// Temporary: Static logo with fade-in until Lottie is ready
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: const Duration(milliseconds: 800),
  ...
),
```

**UNCOMMENT these lines** (around line 33-48):
```dart
Lottie.asset(
  'assets/animations/fulitrack_splash.json',
  controller: _controller,
  onLoaded: (composition) {
    _controller
      ..duration = composition.duration
      ..forward().then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onAnimationComplete();
          }
        });
      });
  },
),
```

### 3.3 Install dependencies
```bash
flutter pub get
```

---

## Step 4: Test the Animation

```bash
# Run on emulator
flutter run

# Or on physical device
flutter run -d <device-id>
```

The animation should:
- ✅ Play once on app launch
- ✅ Last 2.5-3 seconds
- ✅ Automatically transition to main screen
- ✅ Look smooth at 60fps

---

## Step 5: Optimize (Optional)

If the JSON file is > 100KB:

```bash
# Install lottie-cli
npm install -g @lottiefiles/lottie-cli

# Optimize the file
lottie-cli optimize fulitrack_splash.json -o fulitrack_splash_optimized.json
```

Replace the original with the optimized version.

---

## Troubleshooting

### Animation doesn't show
- ✅ Check file path: `assets/animations/fulitrack_splash.json`
- ✅ Run `flutter pub get`
- ✅ Restart the app (not hot reload)

### Animation is too fast/slow
Adjust duration multiplier in `splash_screen.dart`:
```dart
_controller
  ..duration = composition.duration * 1.2 // 20% slower
  ..forward();
```

### Colors look wrong
- Check with animator - may need color adjustment
- Or edit JSON file (search for hex colors and replace)

---

## Current Status

🟡 **TEMPORARY**: Static fade-in animation is active
🔵 **READY FOR**: Lottie JSON integration (code already prepared)

Once you receive `fulitrack_splash.json`, just drop it in `assets/animations/` and uncomment the Lottie code!

---

## Need Help?

1. **Test your JSON first**: [LottieFiles Preview](https://lottiefiles.com/preview)
2. **Edit colors**: [Lottie Editor](https://edit.lottiefiles.com)
3. **Find free animations**: [LottieFiles Library](https://lottiefiles.com/featured)

**Estimated Time**: 5 minutes to integrate after receiving file
