//
//  MessageStore.swift
//  OhYesClient
//
//  ObservableObject to manage messages
//

import Foundation
import Combine

class MessageStore: ObservableObject {
    @Published var messages: [Message] = []

    func addMessage(_ text: String) {
        let message = Message(text: text)
        // Insert at the beginning to show newest messages at top
        messages.insert(message, at: 0)
    }

    func clearMessages() {
        messages.removeAll()
    }
}
