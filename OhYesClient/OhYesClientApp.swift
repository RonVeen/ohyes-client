//
//  OhYesClientApp.swift
//  OhYesClient
//
//  A native macOS client to notify the user when an OhYes reminder is due
//

import SwiftUI
import UserNotifications

@main
struct OhYesClientApp: App {
    @StateObject private var messageStore = MessageStore()
    @StateObject private var pollingService = TodoPollingService()

    init() {
        // Initialize database connection on app launch
        _ = DatabaseManager.shared
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(messageStore)
                .onAppear {
                    // Connect polling service to message store
                    pollingService.messageStore = messageStore
                    // Start polling for due todos
                    pollingService.startPolling()
                }
                .onDisappear {
                    pollingService.stopPolling()
                }
        }
        
        Settings {
            SettingsView()
        }
        .commands {
            // File Menu
            CommandGroup(replacing: .appInfo) {
                Button("About OhYes Client") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationName: "OhYes Client",
                            NSApplication.AboutPanelOptionKey.applicationVersion: "0.1",
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "OhYes Client v.01"
                        ]
                    )
                }
            }

            CommandGroup(replacing: .newItem) {
                // Remove default "New" item
            }

            // View Menu
            CommandMenu("View") {
                Button("Clear") {
                    messageStore.clearMessages()
                }
                .keyboardShortcut("k", modifiers: [.command])
            }
        }
    }
}
