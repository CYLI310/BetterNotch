//
//  AppsView.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI
import AppKit
import Combine

struct AppsView: View {
    @StateObject private var appsManager = MenuBarAppsManager()
    @State private var searchText = ""
    
    let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 16)
    ]
    
    var filteredApps: [MenuBarApp] {
        if searchText.isEmpty {
            return appsManager.apps
        } else {
            return appsManager.apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.4))
                    .font(.system(size: 14))
                
                TextField("Search apps...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Apps Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredApps) { app in
                        AppIconView(app: app) {
                            appsManager.launchApp(app)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct AppIconView: View {
    let app: MenuBarApp
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .scaleEffect(isHovering ? 1.05 : 1.0)
                } else {
                    Image(systemName: "app.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Text(app.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isHovering ? 0.1 : 0.0))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

struct MenuBarApp: Identifiable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let icon: NSImage?
    let path: String
}

class MenuBarAppsManager: ObservableObject {
    @Published var apps: [MenuBarApp] = []
    
    init() {
        loadApps()
    }
    
    func loadApps() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Get common menu bar apps and utilities
            let workspace = NSWorkspace.shared
            
            // Common menu bar app paths
            let appPaths = [
                "/Applications",
                "/System/Applications",
                "/Applications/Utilities"
            ]
            
            var discoveredApps: [MenuBarApp] = []
            
            for path in appPaths {
                if let contents = try? FileManager.default.contentsOfDirectory(atPath: path) {
                    for item in contents where item.hasSuffix(".app") {
                        let fullPath = "\(path)/\(item)"
                        if let bundle = Bundle(path: fullPath),
                           let bundleId = bundle.bundleIdentifier,
                           let appName = bundle.infoDictionary?["CFBundleName"] as? String {
                            
                            let icon = workspace.icon(forFile: fullPath)
                            
                            discoveredApps.append(MenuBarApp(
                                name: appName,
                                bundleIdentifier: bundleId,
                                icon: icon,
                                path: fullPath
                            ))
                        }
                    }
                }
            }
            
            // Sort alphabetically
            let sortedApps = discoveredApps.sorted { $0.name < $1.name }
            
            DispatchQueue.main.async {
                self.apps = sortedApps
                
                // If no apps found, add some common ones manually
                if self.apps.isEmpty {
                    self.loadSampleApps()
                }
            }
        }
    }
    
    func loadSampleApps() {
        // Sample apps for demonstration
        apps = [
            MenuBarApp(
                name: "System Settings",
                bundleIdentifier: "com.apple.systempreferences",
                icon: NSWorkspace.shared.icon(forFile: "/System/Applications/System Settings.app"),
                path: "/System/Applications/System Settings.app"
            ),
            MenuBarApp(
                name: "Activity Monitor",
                bundleIdentifier: "com.apple.ActivityMonitor",
                icon: NSWorkspace.shared.icon(forFile: "/System/Applications/Utilities/Activity Monitor.app"),
                path: "/System/Applications/Utilities/Activity Monitor.app"
            ),
            MenuBarApp(
                name: "Calculator",
                bundleIdentifier: "com.apple.calculator",
                icon: NSWorkspace.shared.icon(forFile: "/System/Applications/Calculator.app"),
                path: "/System/Applications/Calculator.app"
            )
        ]
    }
    
    func launchApp(_ app: MenuBarApp) {
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: app.path),
                                           configuration: NSWorkspace.OpenConfiguration(),
                                           completionHandler: nil)
    }
}
