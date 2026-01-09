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
        messages.append(message)
        
        // Sort by due date descending (newest due date at top)
        // If due date is nil, we treat it as older/lower priority for sorting
        messages.sort { (m1, m2) -> Bool in
            let d1 = m1.dueDate ?? m1.timestamp
            let d2 = m2.dueDate ?? m2.timestamp
            return d1 > d2
        }
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
