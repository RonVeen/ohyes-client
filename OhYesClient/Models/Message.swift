//
//  Message.swift
//  OhYesClient
//
//  Message model
//

import Foundation

struct Message: Identifiable {
    let id: UUID
    let text: String
    let timestamp: Date

    init(id: UUID = UUID(), text: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }
}
