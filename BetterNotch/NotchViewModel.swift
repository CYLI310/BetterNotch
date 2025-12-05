//
//  NotchViewModel.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import Foundation
import SwiftUI
import Combine

class NotchViewModel: ObservableObject {
    @Published var isExpanded = false
    @Published var isHovering = false
    @Published var isPinned = false
    @Published var selectedTab: NotchTab = .media
    
    enum NotchTab: String, CaseIterable {
        case media = "Media"
        case notifications = "Notifications"
        case calendar = "Calendar"
        case apps = "Apps"
        case tray = "Tray"
        
        var icon: String {
            switch self {
            case .media: return "play.circle.fill"
            case .notifications: return "bell.fill"
            case .calendar: return "calendar"
            case .apps: return "square.grid.2x2.fill"
            case .tray: return "tray.fill"
            }
        }
    }
}
