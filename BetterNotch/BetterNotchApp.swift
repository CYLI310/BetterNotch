//
//  BetterNotchApp.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI
import AppKit

@main
struct BetterNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var notchWindow: NotchWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Create the notch window
        notchWindow = NotchWindow()
        notchWindow?.makeKeyAndOrderFront(nil)
    }
}
