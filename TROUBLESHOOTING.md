# BetterNotch - Troubleshooting Guide

## Music Controls Not Working

The music controls require **Automation permissions** to control Spotify and Apple Music via AppleScript.

### Steps to Fix:

1. **Open System Settings** (System Preferences on older macOS)
2. Go to **Privacy & Security**
3. Scroll down and click **Automation**
4. Find **BetterNotch** in the list
5. Enable checkboxes for:
   - ✅ **Spotify** (if you use Spotify)
   - ✅ **Music** (if you use Apple Music)

### Alternative Method:
1. Open **Terminal**
2. Run: `tccutil reset AppleEvents`
3. Restart BetterNotch
4. When you first try to control music, macOS will prompt you to allow automation

### Testing:
1. Open Spotify or Apple Music
2. Start playing a song
3. Hover over the notch area
4. Click the **Media** tab
5. You should see the current track info and controls

---

## Calendar Not Working

The calendar feature requires **Calendar access** permissions.

### Steps to Fix:

1. **Open System Settings**
2. Go to **Privacy & Security**
3. Click **Calendars**
4. Find **BetterNotch** and enable it (check the box)

### Alternative Method:
1. Open **Terminal**
2. Run: `tccutil reset Calendar`
3. Restart BetterNotch
4. The app will prompt you for calendar access

### Testing:
1. Make sure you have some events in your Calendar app
2. Hover over the notch
3. Click the **Calendar** tab
4. You should see your upcoming events

---

## Still Not Working?

### Check Console Logs:
1. Open **Console.app**
2. Search for "BetterNotch"
3. Look for error messages related to permissions

### Reset All Permissions:
```bash
tccutil reset All com.yourname.BetterNotch
```

### Rebuild the App:
1. In Xcode, go to **Product > Clean Build Folder** (Shift+Cmd+K)
2. **Product > Build** (Cmd+B)
3. **Product > Run** (Cmd+R)

---

## Common Issues:

### "No Media Playing" even when music is playing
- Make sure Spotify/Music is actually running
- Check that you've granted Automation permissions
- Try restarting both BetterNotch and the music app

### "No Upcoming Events" even when you have events
- Check Calendar permissions in System Settings
- Make sure events are in the future (not past events)
- Try clicking "Check Permissions" button in the Calendar tab

### App doesn't appear when hovering
- The hover area is at the **top-center** of your screen
- Try moving your mouse slowly to the very top
- If pinned, it should stay visible

---

## Need More Help?

Check the Xcode console output when running the app for detailed error messages.
