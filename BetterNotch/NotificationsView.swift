//
//  NotificationsView.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI
import UserNotifications
import Combine

struct NotificationsView: View {
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Notifications")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                if !notificationManager.notifications.isEmpty {
                    Button(action: { notificationManager.clearAll() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            if notificationManager.notifications.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bell.slash")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.2))
                    
                    Text("No Notifications")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Button("Check Permissions") {
                        notificationManager.requestNotificationPermissions()
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(notificationManager.notifications) { notification in
                            NotificationRow(notification: notification) {
                                notificationManager.removeNotification(notification)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    let onDismiss: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // App Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(notification.color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: notification.icon)
                    .font(.system(size: 14))
                    .foregroundColor(notification.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(notification.timeAgo)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Text(notification.body)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            if isHovering {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.white.opacity(isHovering ? 0.1 : 0.05))
        .cornerRadius(8)
        .padding(.vertical, 2)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let appName: String
    let title: String
    let body: String
    let icon: String
    let color: Color
    let timestamp: Date
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

class NotificationManager: ObservableObject {
    @Published var notifications: [AppNotification] = []
    
    init() {
        // Request notification permissions
        requestNotificationPermissions()
        
        // Don't load sample notifications automatically
        // Real notification integration would go here
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
                // In a real implementation, we would set up notification observers here
            }
        }
    }
    
    func loadSampleNotifications() {
        // Sample notifications for demonstration (can be called manually for testing)
        notifications = [
            AppNotification(
                appName: "Messages",
                title: "John Doe",
                body: "Hey, are we still on for lunch?",
                icon: "message.fill",
                color: .green,
                timestamp: Date().addingTimeInterval(-300)
            ),
            AppNotification(
                appName: "Mail",
                title: "Meeting Reminder",
                body: "Team sync in 15 minutes",
                icon: "envelope.fill",
                color: .blue,
                timestamp: Date().addingTimeInterval(-900)
            ),
            AppNotification(
                appName: "Calendar",
                title: "Upcoming Event",
                body: "Project deadline tomorrow",
                icon: "calendar",
                color: .red,
                timestamp: Date().addingTimeInterval(-3600)
            )
        ]
    }
    
    func removeNotification(_ notification: AppNotification) {
        withAnimation {
            notifications.removeAll { $0.id == notification.id }
        }
    }
    
    func clearAll() {
        withAnimation {
            notifications.removeAll()
        }
    }
}
