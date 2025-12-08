//
//  NotchContentView.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI
import IOKit.ps

struct NotchContentView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.isExpanded {
                ExpandedNotchView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Hover detection area & Collapsed view
                ZStack {
                    Color.clear.frame(height: 32)
                    
                    if viewModel.showCollapsed {
                        CollapsedNotchView()
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity.combined(with: .move(edge: .top).combined(with: .scale(scale: 0.98)))
                            ))
                            .onAppear {
                                viewModel.startHideTimer()
                            }
                    }
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.isExpanded)
        .animation(.easeInOut(duration: 0.6), value: viewModel.showCollapsed)
    }
}

struct CollapsedNotchView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Text(viewModel.currentTime, style: .time)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .frame(minWidth: 80)
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: viewModel.isCharging ? "bolt.fill" : "battery.100")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(Int(viewModel.batteryLevel * 100))%")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(height: 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black) // Solid black
        )
    }
}

struct ExpandedNotchView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    @State private var currentPage = 1 // 0: System, 1: Time, 2: Apps. Default: Time
    
    // System Page State
    @State private var cpuUsage: Double = 0.0
    @State private var memoryUsage: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black
                
                // Content pages
                HStack(spacing: 0) {
                    SystemUsagePage(cpuUsage: $cpuUsage, memoryUsage: $memoryUsage)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    TimePage()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    AppsPage()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .offset(x: -CGFloat(currentPage) * geometry.size.width)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                
                // Invisible overlay to capture scroll events
                ScrollWheelGestureView { deltaX, deltaY in
                    // Use horizontal scroll for page switching
                    if abs(deltaX) > abs(deltaY) {
                        if deltaX < -15 { // Scroll left (swipe right on trackpad)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if currentPage > 0 {
                                    currentPage -= 1
                                }
                            }
                        } else if deltaX > 15 { // Scroll right (swipe left on trackpad)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if currentPage < 2 {
                                    currentPage += 1
                                }
                            }
                        }
                    }
                }
                
                // Page indicator
                VStack {
                    Spacer()
                    PageIndicator(currentPage: currentPage, totalPages: 3)
                        .padding(.bottom, 12)
                }
            }
        }
        .cornerRadius(32)
        .onAppear {
            updateSystemInfo()
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                updateSystemInfo()
            }
        }
    }
    
    func updateSystemInfo() {
        cpuUsage = Double.random(in: 10...60)
        memoryUsage = Double.random(in: 40...80)
        viewModel.updateBatteryInfo()
    }
    
    struct PageIndicator: View {
        let currentPage: Int
        let totalPages: Int
        
        var body: some View {
            HStack(spacing: 6) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

// Custom NSView wrapper to capture scroll wheel events
struct ScrollWheelGestureView: NSViewRepresentable {
    let onScroll: (CGFloat, CGFloat) -> Void
    
    func makeNSView(context: Context) -> ScrollWheelNSView {
        let view = ScrollWheelNSView()
        view.onScroll = onScroll
        return view
    }
    
    func updateNSView(_ nsView: ScrollWheelNSView, context: Context) {
        nsView.onScroll = onScroll
    }
    
    class ScrollWheelNSView: NSView {
        var onScroll: ((CGFloat, CGFloat) -> Void)?
        private var scrollAccumulator: CGFloat = 0
        private var lastScrollTime: Date = Date()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func scrollWheel(with event: NSEvent) {
            let now = Date()
            let timeDiff = now.timeIntervalSince(lastScrollTime)
            
            // Reset accumulator if too much time has passed
            if timeDiff > 0.3 {
                scrollAccumulator = 0
            }
            
            scrollAccumulator += event.scrollingDeltaX
            
            // Trigger page change when accumulated scroll exceeds threshold
            if abs(scrollAccumulator) > 15 {
                onScroll?(scrollAccumulator, event.scrollingDeltaY)
                scrollAccumulator = 0
            }
            
            lastScrollTime = now
        }
    }
}



// MARK: - Pages

struct SystemUsagePage: View {
    @EnvironmentObject var viewModel: NotchViewModel
    @Binding var cpuUsage: Double
    @Binding var memoryUsage: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("System")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 24)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SystemInfoCard(icon: "cpu", title: "CPU", value: "\(Int(cpuUsage))%", color: .blue)
                SystemInfoCard(icon: "memorychip", title: "Memory", value: "\(Int(memoryUsage))%", color: .purple)
                SystemInfoCard(
                    icon: viewModel.isCharging ? "bolt.fill" : "battery.100",
                    title: "Battery",
                    value: "\(Int(viewModel.batteryLevel * 100))%",
                    color: viewModel.isCharging ? .green : .orange
                )
                SystemInfoCard(icon: "wifi", title: "Network", value: "On", color: .cyan)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

struct TimePage: View {
    @EnvironmentObject var viewModel: NotchViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text(viewModel.currentTime, style: .time)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
            
            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
        }
        .padding(32)
    }
}

struct AppsPage: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Apps")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 24)
                .padding(.bottom, 16)
            
            AppsView()
                .padding(.horizontal, 16)
            
            Spacer()
        }
    }
}

// MARK: - Components

struct SystemInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}
