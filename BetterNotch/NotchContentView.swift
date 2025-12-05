//
//  NotchContentView.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI

struct NotchContentView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.isExpanded {
                ExpandedNotchView()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                // Completely invisible collapsed state - just a transparent rectangle for hover detection
                Color.clear
                    .frame(height: 32)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.isExpanded)
    }
}

struct ExpandedNotchView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with tabs
            NotchHeaderView()
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Content area
            TabView(selection: $viewModel.selectedTab) {
                MediaControlView()
                    .tag(NotchViewModel.NotchTab.media)
                
                NotificationsView()
                    .tag(NotchViewModel.NotchTab.notifications)
                
                CalendarView()
                    .tag(NotchViewModel.NotchTab.calendar)
                
                AppsView()
                    .tag(NotchViewModel.NotchTab.apps)
                
                TrayView()
                    .tag(NotchViewModel.NotchTab.tray)
            }
            .tabViewStyle(.automatic)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.12)) // Dark grey, Control Center style
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct NotchHeaderView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Tab buttons
            ForEach(NotchViewModel.NotchTab.allCases, id: \.self) { tab in
                TabButton(tab: tab, isSelected: viewModel.selectedTab == tab) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTab = tab
                    }
                }
            }
            
            Spacer()
            
            // Pin button
            Button(action: {
                viewModel.isPinned.toggle()
            }) {
                Image(systemName: viewModel.isPinned ? "pin.fill" : "pin")
                    .foregroundColor(viewModel.isPinned ? .white : .white.opacity(0.4))
                    .font(.system(size: 12))
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(viewModel.isPinned ? Color.white.opacity(0.15) : Color.clear)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

struct TabButton: View {
    let tab: NotchViewModel.NotchTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 15))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            }
            .frame(width: 50, height: 46)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// Visual Effect Blur helper
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
