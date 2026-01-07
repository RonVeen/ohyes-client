//
//  Message.swift
//  OhYesClient
//
//  Message model
//

import Foundation

struct Message: Identifiable {
    let id: UUID
    let originalTodoId: Int64?
    let text: String
    let timestamp: Date
    let priority: Int
    let dueDate: Date?

    init(id: UUID = UUID(), originalTodoId: Int64? = nil, text: String, timestamp: Date = Date(), priority: Int = 0, dueDate: Date? = nil) {
        self.id = id
        self.originalTodoId = originalTodoId
        self.text = text
        self.timestamp = timestamp
        self.priority = priority
        self.dueDate = dueDate
    }
}
