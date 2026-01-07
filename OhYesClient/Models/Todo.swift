//
//  Todo.swift
//  OhYesClient
//
//  Todo model matching the database schema
//

import Foundation

struct Todo {
    let id: Int64
    let created: Date
    let text: String
    let comment: String?
    let completed: Bool
    let due: Date?
    let priority: Int

    init(id: Int64, created: Date, text: String, comment: String?, completed: String, due: Date?, priority: Int) {
        self.id = id
        self.created = created
        self.text = text
        self.comment = comment
        self.completed = (completed == "Y")
        self.due = due
        self.priority = priority
    }

    var isDue: Bool {
        guard let dueDate = due else { return false }
        return dueDate <= Date() && !completed
    }
}
