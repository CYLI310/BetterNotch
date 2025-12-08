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
            } else {
                // Always show a hover area, but only show the collapsed UI if showCollapsed is true
                ZStack {
                    // Invisible hover detection area (always present)
                    Color.clear
                        .frame(height: 32)
                    
                    // Visible collapsed UI (conditionally shown)
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
            // Time display
            Text(viewModel.currentTime, style: .time)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .frame(minWidth: 80)
            
            Spacer()
            
            // Battery indicator
            HStack(spacing: 6) {
                Image(systemName: viewModel.isCharging ? "bolt.fill" : "battery.100")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(Int(viewModel.batteryLevel * 100))%")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(height: 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct ExpandedNotchView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    @State private var cpuUsage: Double = 0.0
    @State private var memoryUsage: Double = 0.0
    @State private var selectedTab: ExpandedTab = .info
    
    enum ExpandedTab {
        case info
        case apps
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content area with smooth transition
            ZStack {
                if selectedTab == .info {
                    InfoTabView(cpuUsage: $cpuUsage, memoryUsage: $memoryUsage)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                } else {
                    AppsTabView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom tab indicator
            HStack(spacing: 12) {
                TabButton(
                    icon: "info.circle.fill",
                    isSelected: selectedTab == .info,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = .info
                        }
                    }
                )
                
                TabButton(
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedTab == .apps,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = .apps
                        }
                    }
                )
            }
            .padding(.vertical, 12)
            .padding(.bottom, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 15)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .onAppear {
            updateSystemInfo()
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                updateSystemInfo()
            }
        }
    }
    
    func updateSystemInfo() {
        // Update CPU usage (simplified)
        cpuUsage = Double.random(in: 10...60)
        
        // Update memory usage (simplified)
        memoryUsage = Double.random(in: 40...80)
        
        // Update battery
        viewModel.updateBatteryInfo()
    }
}

struct TabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.white.opacity(0.15) : (isHovering ? Color.white.opacity(0.08) : Color.clear))
                )
                .scaleEffect(isHovering ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

struct InfoTabView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    @Binding var cpuUsage: Double
    @Binding var memoryUsage: Double
    
    var body: some View {
        VStack(spacing: 0) {
            // Large time and date display
            VStack(spacing: 8) {
                Text(viewModel.currentTime, style: .time)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(viewModel.currentTime, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 24)
            
            // System info grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SystemInfoCard(
                    icon: "cpu",
                    title: "CPU",
                    value: "\(Int(cpuUsage))%",
                    color: .blue
                )
                
                SystemInfoCard(
                    icon: "memorychip",
                    title: "Memory",
                    value: "\(Int(memoryUsage))%",
                    color: .purple
                )
                
                SystemInfoCard(
                    icon: viewModel.isCharging ? "bolt.fill" : "battery.100",
                    title: "Battery",
                    value: "\(Int(viewModel.batteryLevel * 100))%",
                    color: viewModel.isCharging ? .green : .orange
                )
                
                SystemInfoCard(
                    icon: "wifi",
                    title: "Network",
                    value: "Connected",
                    color: .cyan
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Spacer(minLength: 0)
        }
    }
}

struct AppsTabView: View {
    @State private var hasError = false
    
    var body: some View {
        if hasError {
            // Fallback UI if AppsView crashes
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                
                Text("Unable to load apps")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Please try again later")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            AppsView()
                .onAppear {
                    // Give AppsView a moment to load
                }
        }
    }
}

struct SystemInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .scaleEffect(isHovering ? 1.1 : 1.0)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isHovering ? 0.08 : 0.05))
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}
