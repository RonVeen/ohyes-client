//
//  NotificationDelegate.swift
//  OhYesClient
//
//  Delegate to handle user notifications, specifically allowing them to present
//  even when the application is in the foreground.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    
    // This method is called when a notification is delivered to a foreground app.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and play sound even if app is in foreground
        completionHandler([.banner, .list, .sound])
    }
}
