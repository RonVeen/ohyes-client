//
//  TodoPollingService.swift
//  OhYesClient
//
//  Service that polls for due todos every minute
//

import Foundation
import AppKit
import UserNotifications

class TodoPollingService: ObservableObject {
    private var timer: Timer?
    private let databaseManager = DatabaseManager.shared
    private var notifiedTodoIds = Set<Int64>()
    weak var messageStore: MessageStore?

    func startPolling() {
        print("Starting todo polling service...")

        // Check immediately on start
        checkForDueTodos()

        // Then check every 60 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkForDueTodos()
        }
    }

    func stopPolling() {
        print("Stopping todo polling service...")
        timer?.invalidate()
        timer = nil
    }

    private func checkForDueTodos() {
        print("Checking for due todos at \(Date())...")
        let dueTodos = databaseManager.fetchDueTodos()

        for todo in dueTodos {
            // Only notify if we haven't already notified about this todo
            if !notifiedTodoIds.contains(todo.id) {
                notifyUser(for: todo)
                notifiedTodoIds.insert(todo.id)
            }
        }

        if !dueTodos.isEmpty {
            print("Found \(dueTodos.count) due todo(s)")
        }
    }

    private func notifyUser(for todo: Todo) {
        print("Todo is due: \(todo.text)")

        // Add message to the text view
        DispatchQueue.main.async { [weak self] in
            self?.messageStore?.addMessage(todo.text)
        }

        // Send system notification
        let content = UNMutableNotificationContent()
        content.title = "OhYes Reminder"
        content.body = todo.text
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: "todo-\(todo.id)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            }
        }
    }

    deinit {
        stopPolling()
    }
}
