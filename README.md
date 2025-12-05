# BetterNotch - Simplified Edition

A minimal, elegant macOS menu bar enhancement that sits at the top of your screen, providing quick access to essential system information and your favorite apps.

![Updated Notch Design](updated_notch_design.png)

## ✨ Features

### Collapsed State (Auto-hides after 4 seconds)
- **Current Time** - Always visible at a glance
- **Battery Status** - Shows battery percentage and charging state
- **Auto-hide** - Disappears after 4 seconds, reappears on mouse movement

### Expanded State (On Hover)
- **Always-Visible Top Bar**:
  - Current time with icon
  - Reactive tab buttons
  - Battery status with icon

- **Info Tab**:
  - 🕐 Large Clock Display
  - 📅 Date Information (weekday, month, day)
  - 💻 CPU Usage
  - 🧠 Memory Usage
  - 🔋 Battery Level & Charging Status
  - 📡 Network Connectivity

- **Apps Tab**:
  - 🔍 Search bar to filter apps
  - 📱 Grid of installed applications
  - 🚀 Click to launch any app
  - ✨ Hover effects and smooth animations

## 🎨 Design Philosophy

BetterNotch follows a **minimal yet functional** approach:
- Clean interface with reactive tab navigation
- Essential system info + quick app launcher
- Smooth animations and transitions
- Positioned at the very top of the screen (no menu bar offset)
- Auto-hides after 4 seconds to keep your screen clean
- Time and battery always visible in expanded state

## 🚀 Getting Started

### Requirements
- macOS 12.0 or later
- Xcode 14.0 or later
- A Mac with a notch (or any Mac - it works on all models!)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd BetterNotch
   ```

2. **Open in Xcode**
   ```bash
   open BetterNotch.xcodeproj
   ```

3. **Build and Run**
   - Press `⌘R` or click the Run button
   - The notch will appear at the top of your screen

### First Launch

When you first run BetterNotch:
1. The app will hide from the Dock (runs as an accessory)
2. A small notch will appear at the top center of your screen
3. Hover over it to see the expanded view
4. Move your mouse away to auto-collapse

## 🎯 Usage

### Interactions
- **Hover** - Expand the notch to see detailed info
- **Click Info Tab** - View system information (CPU, memory, battery, network)
- **Click Apps Tab** - Browse and launch installed applications
- **Search Apps** - Type in the search bar to filter apps quickly
- **Move Away** - Auto-collapses after 0.3 seconds
- **Wait 4 Seconds** - Collapsed view auto-hides to keep screen clean
- **Move to Top** - Collapsed view reappears when you move mouse to top of screen

### Quitting the App
Since there's no menu bar icon, use one of these methods:
- Press `⌘Q` while the notch is focused
- Use Activity Monitor to quit the app
- Add a keyboard shortcut in the code (optional)

## 🛠️ Customization

### Changing Update Intervals

**Time Updates** (NotchViewModel.swift):
```swift
timer = Timer.publish(every: 1, on: .main, in: .common) // Change 1 to desired seconds
```

**System Info Updates** (NotchContentView.swift):
```swift
Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) // Change 2.0 to desired seconds
```

### Adjusting Dimensions

**Collapsed Size** (NotchWindow.swift):
```swift
let notchWidth: CGFloat = 350  // Adjust width
let notchHeight: CGFloat = 32  // Adjust height
```

**Expanded Size** (NotchWindow.swift):
```swift
let expandedWidth: CGFloat = 600   // Adjust width
let expandedHeight: CGFloat = 450  // Adjust height
```

### Changing Auto-Hide Duration

**Auto-hide Timer** (NotchViewModel.swift):
```swift
hideTimer = Timer.publish(every: 4, on: .main, in: .common) // Change 4 to desired seconds
```

### Changing Colors

All colors are defined in `NotchContentView.swift`:
- Background: `Color(red: 0.12, green: 0.12, blue: 0.12)`
- Card backgrounds: `Color.white.opacity(0.05)`
- Text: `.white` with various opacities

## 📁 Project Structure

```
BetterNotch/
├── BetterNotch/
│   ├── BetterNotchApp.swift      # App entry point
│   ├── NotchWindow.swift         # Window management
│   ├── NotchViewModel.swift      # State management
│   ├── NotchContentView.swift    # UI components
│   └── Assets.xcassets/          # App assets
├── SIMPLIFICATION_SUMMARY.md     # Change log
└── README.md                     # This file
```

## 🔧 Technical Details

### Architecture
- **SwiftUI** for UI components
- **AppKit** for window management
- **Combine** for reactive updates
- **IOKit** for battery monitoring

### Key Components

1. **NotchWindow** - Custom NSWindow that:
   - Positions at screen top
   - Handles hover detection
   - Manages expand/collapse animations

2. **NotchViewModel** - ObservableObject that:
   - Tracks expansion state
   - Updates time every second
   - Monitors battery status

3. **NotchContentView** - SwiftUI views that:
   - Display collapsed/expanded states
   - Show system information
   - Handle user interactions

## 🐛 Known Limitations

1. **System Metrics** - CPU and Memory usage currently show placeholder values. Real implementation requires:
   - `host_statistics()` for CPU
   - `task_info()` for memory

2. **Network Status** - Currently shows "Connected" as placeholder. Real implementation would use:
   - `NWPathMonitor` from Network framework

3. **No Menu Bar Icon** - The app has no menu bar presence. Consider adding one if you need easy access to preferences or quit options.

## 🎁 What Was Removed

This simplified version removed:
- ❌ Media player controls
- ❌ Notifications view
- ❌ Calendar integration
- ❌ Apps launcher
- ❌ Tray functionality
- ❌ Tab navigation
- ❌ Menu bar status item

## 🔮 Future Enhancements

Potential additions (if desired):
- [ ] Real CPU/Memory monitoring
- [ ] Network speed display
- [ ] Weather information
- [ ] Keyboard shortcuts
- [ ] Preferences window
- [ ] Menu bar icon (optional)
- [ ] Custom themes

## 📝 License

[Add your license here]

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 💬 Support

If you encounter issues:
1. Check the `TROUBLESHOOTING.md` file
2. Open an issue on GitHub
3. Review the code comments for guidance

---

**Made with ❤️ for macOS**
