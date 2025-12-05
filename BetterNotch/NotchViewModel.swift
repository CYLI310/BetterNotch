//
//  NotchViewModel.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import Foundation
import SwiftUI
import Combine
import IOKit.ps

class NotchViewModel: ObservableObject {
    @Published var isExpanded = false
    @Published var isHovering = false
    @Published var isPinned = false
    @Published var currentTime = Date()
    @Published var batteryLevel: Float = 0.0
    @Published var isCharging = false
    @Published var showCollapsed = true
    
    private var timer: AnyCancellable?
    private var hideTimer: AnyCancellable?
    
    init() {
        // Update time every second
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.currentTime = date
            }
        
        // Update battery info
        updateBatteryInfo()
    }
    
    func updateBatteryInfo() {
        // Get battery info from IOKit
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        for source in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as! [String: AnyObject]
            
            if let capacity = info[kIOPSCurrentCapacityKey] as? Int,
               let maxCapacity = info[kIOPSMaxCapacityKey] as? Int {
                batteryLevel = Float(capacity) / Float(maxCapacity)
            }
            
            if let charging = info[kIOPSIsChargingKey] as? Bool {
                isCharging = charging
            }
        }
    }
    
    func startHideTimer() {
        hideTimer?.cancel()
        showCollapsed = true
        
        hideTimer = Timer.publish(every: 4, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if !self.isExpanded && !self.isHovering {
                    self.showCollapsed = false
                }
            }
    }
    
    func resetHideTimer() {
        hideTimer?.cancel()
        showCollapsed = true
        startHideTimer()
    }
}
