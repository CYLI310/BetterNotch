# 🚀 Quick Start Guide

Get BetterNotch up and running in 2 minutes!

## Step 1: Open the Project

The project is already open in Xcode. If not:
```bash
cd /Users/justinli/Documents/BetterNotch
open BetterNotch.xcodeproj
```

## Step 2: Build & Run

**Option A: Using Xcode**
1. Press `⌘R` (or click the ▶️ Run button)
2. Wait for the build to complete
3. The notch will appear at the top of your screen!

**Option B: Using Terminal** (if Xcode is installed)
```bash
cd /Users/justinli/Documents/BetterNotch
xcodebuild -project BetterNotch.xcodeproj -scheme BetterNotch -configuration Debug
```

## Step 3: Try It Out!

1. **Look at the top of your screen** - You'll see a small dark pill showing the time and battery
2. **Hover your mouse over it** - It will expand to show detailed system info
3. **Move your mouse away** - It will automatically collapse after 0.3 seconds
4. **Click "Close"** in the expanded view - Manually collapse it

## What You'll See

### Collapsed State
```
┌──────────────────────────┐
│  3:53 PM      🔋 85%    │
└──────────────────────────┘
```

### Expanded State (on hover)
```
┌────────────────────────────────┐
│                                │
│         3:53 PM                │
│   Thursday, December 5         │
│ ────────────────────────────── │
│                                │
│  💻 CPU    🧠 Memory          │
│   45%       68%               │
│                                │
│  🔋 Battery 📡 Network        │
│   85%      Connected          │
│                                │
│       [ Close ]                │
└────────────────────────────────┘
```

## Troubleshooting

### "Build Failed"
- Make sure you have Xcode installed (not just Command Line Tools)
- Check that all files are included in the Xcode project
- Try cleaning the build folder: `⌘⇧K`

### "Nothing Appears"
- Check if the app is running in Activity Monitor
- The notch is at the **very top** of the screen (not below menu bar)
- Try moving your mouse to the top center of the screen

### "Can't Quit the App"
Since there's no menu bar icon:
1. **Method 1:** Click on the notch, then press `⌘Q`
2. **Method 2:** Open Activity Monitor → Find "BetterNotch" → Quit
3. **Method 3:** Run in terminal: `killall BetterNotch`

## Next Steps

### Customize It
- Edit `NotchContentView.swift` to change colors or layout
- Modify `NotchWindow.swift` to adjust dimensions
- Update `NotchViewModel.swift` to change update intervals

### Add Features
- Implement real CPU/Memory monitoring
- Add weather information
- Create a preferences window
- Add keyboard shortcuts

### Clean Up (Optional)
Remove old unused files:
```bash
cd /Users/justinli/Documents/BetterNotch
./cleanup_old_files.sh
```

## Files Overview

| File | Purpose |
|------|---------|
| `BetterNotchApp.swift` | App entry point |
| `NotchWindow.swift` | Window positioning & animations |
| `NotchViewModel.swift` | State management & data |
| `NotchContentView.swift` | UI components |

## Keyboard Shortcuts (when notch is focused)

- `⌘Q` - Quit the app
- `Esc` - Collapse the notch (if expanded)

## Tips

1. **Performance:** The app uses minimal resources - updates time every 1s, system info every 2s
2. **Privacy:** All data is local - no network requests or data collection
3. **Compatibility:** Works on any Mac, not just those with a physical notch
4. **Customization:** All colors, sizes, and timings are easily adjustable in the code

## Need Help?

- Check `README.md` for detailed documentation
- See `SIMPLIFICATION_SUMMARY.md` for what changed
- Review `BEFORE_AFTER.md` for comparison with old version
- Look at `TROUBLESHOOTING.md` for common issues

---

**Enjoy your simplified, beautiful notch! 🎉**
