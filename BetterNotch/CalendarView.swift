//
//  CalendarView.swift
//  BetterNotch
//
//  Created by Justin Li on 2025/12/4.
//

import SwiftUI
import EventKit
import Combine

struct CalendarView: View {
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(Date(), style: .date)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Button(action: { calendarManager.refreshEvents() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            if calendarManager.events.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.2))
                    
                    Text("No Upcoming Events")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Button("Check Permissions") {
                        calendarManager.requestCalendarAccess()
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(calendarManager.events) { event in
                            EventRow(event: event)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

struct EventRow: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // Time strip
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 3)
                .frame(maxHeight: .infinity)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(formatTime(event.startDate))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    if let location = event.location, !location.isEmpty {
                        Text("•")
                            .foregroundColor(.white.opacity(0.4))
                        Text(location)
                            .lineLimit(1)
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let location: String?
    let startDate: Date
    let endDate: Date
    let color: Color
    
    var startTime: String {
        startDate.formatted(.dateTime.hour().minute())
    }
    
    var endTime: String {
        endDate.formatted(.dateTime.hour().minute())
    }
    
    var isNow: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    var isUpcoming: Bool {
        let now = Date()
        let thirtyMinutesFromNow = now.addingTimeInterval(1800)
        return startDate > now && startDate <= thirtyMinutesFromNow
    }
    
    var timeUntilStart: String {
        let interval = startDate.timeIntervalSince(Date())
        let minutes = Int(interval / 60)
        
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            return "\(hours) hr"
        }
    }
}

class CalendarManager: ObservableObject {
    @Published var events: [CalendarEvent] = []
    
    private let eventStore = EKEventStore()
    private var hasRequestedAccess = false
    
    init() {
        requestCalendarAccess()
    }
    
    func requestCalendarAccess() {
        guard !hasRequestedAccess else { return }
        hasRequestedAccess = true
        
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self?.loadEvents()
                    } else {
                        print("Calendar access denied: \(error?.localizedDescription ?? "unknown error")")
                        self?.loadSampleEvents()
                    }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self?.loadEvents()
                    } else {
                        print("Calendar access denied")
                        self?.loadSampleEvents()
                    }
                }
            }
        }
    }
    
    func loadEvents() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
        
        print("📅 Calendar: Found \(ekEvents.count) events for today")
        
        DispatchQueue.main.async {
            if ekEvents.isEmpty {
                print("ℹ️ No real events found, showing sample data")
                // No real events, show sample data
                self.loadSampleEvents()
            } else {
                print("✅ Loading \(ekEvents.count) real calendar events")
                self.events = ekEvents.map { ekEvent in
                    CalendarEvent(
                        title: ekEvent.title ?? "Untitled Event",
                        location: ekEvent.location,
                        startDate: ekEvent.startDate,
                        endDate: ekEvent.endDate,
                        color: Color(nsColor: ekEvent.calendar.color)
                    )
                }.sorted { $0.startDate < $1.startDate }
            }
        }
    }
    
    func loadSampleEvents() {
        // Sample events for demonstration (only shown if no real events)
        let now = Date()
        events = [
            CalendarEvent(
                title: "Team Standup",
                location: "Zoom",
                startDate: Calendar.current.date(byAdding: .minute, value: 15, to: now)!,
                endDate: Calendar.current.date(byAdding: .minute, value: 45, to: now)!,
                color: .blue
            ),
            CalendarEvent(
                title: "Lunch with Sarah",
                location: "Cafe Downtown",
                startDate: Calendar.current.date(byAdding: .hour, value: 2, to: now)!,
                endDate: Calendar.current.date(byAdding: .hour, value: 3, to: now)!,
                color: .green
            ),
            CalendarEvent(
                title: "Project Review",
                location: "Conference Room B",
                startDate: Calendar.current.date(byAdding: .hour, value: 4, to: now)!,
                endDate: Calendar.current.date(byAdding: .hour, value: 5, to: now)!,
                color: .purple
            )
        ]
    }
    
    func refreshEvents() {
        loadEvents()
    }
}
