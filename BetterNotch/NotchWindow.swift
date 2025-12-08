//
//  NotchWindow.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI
import AppKit

class NotchWindow: NSWindow {
    private var notchViewModel = NotchViewModel()
    private var trackingArea: NSTrackingArea?
    private var isAnimating = false
    
    init() {
        // Start with collapsed notch frame
        let notchFrame = NotchWindow.calculateNotchFrame()
        
        super.init(
            contentRect: notchFrame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Window configuration
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
        self.isMovable = false
        self.hasShadow = false // No shadow in collapsed state
        
        // Allow mouse events
        self.ignoresMouseEvents = false
        
        // Set view model to collapsed state
        notchViewModel.isExpanded = false
        
        // Set up the SwiftUI content
        let contentView = NotchContentView()
            .environmentObject(notchViewModel)
        
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.wantsLayer = true
        hostingView.layer?.masksToBounds = false // Allow shadows to show
        hostingView.layer?.cornerRadius = 0 // Let SwiftUI handle corners
        
        self.contentView = hostingView
        
        // Setup mouse tracking
        setupTrackingArea()
    }
    
    static func calculateNotchFrame() -> NSRect {
        guard let screen = NSScreen.main else {
            return NSRect(x: 0, y: 0, width: 350, height: 32)
        }
        
        let screenFrame = screen.frame
        let notchWidth: CGFloat = 350
        let notchHeight: CGFloat = 32
        
        // Center horizontally, position at the very top of the screen
        let x = screenFrame.origin.x + (screenFrame.width - notchWidth) / 2
        let y = screenFrame.origin.y + screenFrame.height - notchHeight
        
        return NSRect(x: x, y: y, width: notchWidth, height: notchHeight)
    }
    
    static func calculateExpandedFrame() -> NSRect {
        guard let screen = NSScreen.main else {
            return NSRect(x: 0, y: 0, width: 600, height: 480)
        }
        
        let expandedWidth: CGFloat = 600
        let expandedHeight: CGFloat = 480
        
        let x = screen.frame.origin.x + (screen.frame.width - expandedWidth) / 2
        let y = screen.frame.origin.y + screen.frame.height - expandedHeight
        
        return NSRect(x: x, y: y, width: expandedWidth, height: expandedHeight)
    }
    
    func setupTrackingArea() {
        if let trackingArea = trackingArea {
            contentView?.removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .mouseMoved,
            .activeAlways,
            .inVisibleRect
        ]
        
        trackingArea = NSTrackingArea(
            rect: .zero,
            options: options,
            owner: self,
            userInfo: nil
        )
        
        if let trackingArea = trackingArea {
            contentView?.addTrackingArea(trackingArea)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        notchViewModel.isHovering = true
        notchViewModel.resetHideTimer()
        expandNotch()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        notchViewModel.isHovering = false
        
        // Delay collapse to allow for interaction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            if !self.notchViewModel.isHovering && !self.notchViewModel.isPinned {
                self.collapseNotch()
            }
        }
    }
    
    func expandNotch() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let newFrame = NotchWindow.calculateExpandedFrame()
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().setFrame(newFrame, display: true)
        }, completionHandler: {
            self.isAnimating = false
        })
        
        self.hasShadow = true
        notchViewModel.isExpanded = true
    }
    
    func collapseNotch() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let notchFrame = NotchWindow.calculateNotchFrame()
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().setFrame(notchFrame, display: true)
        }, completionHandler: {
            self.isAnimating = false
        })
        
        self.hasShadow = false
        notchViewModel.isExpanded = false
    }
    
    func toggleExpanded() {
        if notchViewModel.isExpanded {
            notchViewModel.isPinned = false
            collapseNotch()
        } else {
            expandNotch()
            notchViewModel.isPinned = true
        }
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
