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

    func addMessage(_ text: String, originalTodoId: Int64? = nil, priority: Int = 0, dueDate: Date? = nil) {
        let message = Message(
            originalTodoId: originalTodoId,
            text: text,
            priority: priority,
            dueDate: dueDate
        )
        // Insert at the beginning to show newest messages at top
        messages.insert(message, at: 0)
    }

    func clearMessages() {
        messages.removeAll()
    }
    
    func markAsDone(_ message: Message) {
        // Update database if linked to a real todo
        if let todoId = message.originalTodoId {
            DatabaseManager.shared.markTodoAsCompleted(id: todoId)
        }
        
        // Remove from local list
        removeMessage(message)
    }
    
    func snoozeMessage(_ message: Message, minutes: Int) {
        guard let todoId = message.originalTodoId else { return }
        
        // Calculate new due date (from now + minutes)
        let newDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        
        // Update database
        DatabaseManager.shared.updateTodoDueDate(id: todoId, newDate: newDate)
        
        // Remove from local list as it is no longer "due"
        removeMessage(message)
    }
    
    private func removeMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages.remove(at: index)
        }
    }
}
