# Size & Corner Adjustments

## Changes Made

### 1. **Smaller Expanded Size** 📐
- **Previous:** 600px × 450px
- **New:** 520px × 380px
- **Reduction:** 80px width, 70px height
- **Benefit:** More compact, less screen real estate used

### 2. **More Rounded Corners** 🔄
- **Previous:** 24px corner radius
- **New:** 32px corner radius
- **Increase:** +33% rounder
- **Benefit:** Softer, more modern appearance

## Visual Comparison

### Before
```
┌─────────────────────────────────────────────┐
│  600px wide × 450px tall                   │
│  Corner radius: 24px                       │
│  (Slightly angular corners)                │
└─────────────────────────────────────────────┘
```

### After
```
╭──────────────────────────────────────╮
│  520px wide × 380px tall            │
│  Corner radius: 32px                │
│  (Noticeably rounder corners)       │
╰──────────────────────────────────────╯
```

## Files Modified

1. **NotchWindow.swift**
   - Line 65: `width: 600` → `width: 520`
   - Line 66: `height: 450` → `height: 380`

2. **NotchContentView.swift**
   - Line 167: `cornerRadius: 24` → `cornerRadius: 32`
   - Line 172: `cornerRadius: 24` → `cornerRadius: 32`
   - Line 175: `cornerRadius: 24` → `cornerRadius: 32`

## Result

The expanded notch is now:
- ✅ More compact (13% smaller width, 16% smaller height)
- ✅ Rounder corners (33% increase in radius)
- ✅ More elegant and modern appearance
- ✅ Better proportions for the content

Perfect for a cleaner, more refined look! 🎨
