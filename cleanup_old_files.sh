#!/bin/bash

# BetterNotch Cleanup Script
# This script removes the old, unused view files that were part of the complex interface

echo "🧹 BetterNotch Cleanup Script"
echo "=============================="
echo ""
echo "This will remove the following unused files:"
echo "  - MediaControlView.swift"
echo "  - MediaPlayerBridge.swift"
echo "  - NotificationsView.swift"
echo "  - CalendarView.swift"
echo "  - AppsView.swift"
echo "  - TrayView.swift"
echo ""
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]
then
    cd "$(dirname "$0")/BetterNotch"
    
    echo "Removing old view files..."
    rm -f MediaControlView.swift
    rm -f MediaPlayerBridge.swift
    rm -f NotificationsView.swift
    rm -f CalendarView.swift
    rm -f AppsView.swift
    rm -f TrayView.swift
    
    echo "✅ Cleanup complete!"
    echo ""
    echo "Note: You may need to remove these files from your Xcode project as well."
    echo "In Xcode: Right-click each file → Delete → Move to Trash"
else
    echo "❌ Cleanup cancelled."
fi
