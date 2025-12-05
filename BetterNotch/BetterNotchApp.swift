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
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Create the notch window
        notchWindow = NotchWindow()
        notchWindow?.makeKeyAndOrderFront(nil)
        
        // Create menu bar item
        setupMenuBar()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: "BetterNotch")
            button.action = #selector(toggleNotch)
            button.target = self
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Notch", action: #selector(toggleNotch), keyEquivalent: "n"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit BetterNotch", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func toggleNotch() {
        notchWindow?.toggleExpanded()
    }
    
    @objc func openPreferences() {
        // TODO: Implement preferences window
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
