//
//  DatabaseManager.swift
//  OhYesClient
//
//  SQLite database connection and management
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: Connection?
    private let configManager = ConfigManager.shared

    // Table and column definitions
    private let todoTable = Table("Todo")
    private let id = Expression<Int64>("id")
    private let created = Expression<Int64>("created")
    private let text = Expression<String>("text")
    private let comment = Expression<String?>("comment")
    private let completed = Expression<String>("completed")
    private let due = Expression<Int64?>("due")
    private let priority = Expression<Int64>("priority")

    private init() {
        connectToDatabase()
    }

    func connectToDatabase() {
        let dbPath = configManager.expandedDatabasePath()

        do {
            db = try Connection(dbPath)
            print("Successfully connected to database at: \(dbPath)")
        } catch {
            print("Error connecting to database: \(error)")
        }
    }
    
    func reconnect() {
        print("Reconnecting to database...")
        connectToDatabase()
    }

    func getConnection() -> Connection? {
        return db
    }

    // Fetch all due todos (not completed and due time has passed)
    func fetchDueTodos() -> [Todo] {
        guard let database = db else {
            print("Database connection not available")
            return []
        }

        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)

        do {
            let query = todoTable
                .filter(completed == "N")
                .filter(due != nil)
                .filter(due <= currentTime)
                .order(priority.desc, due.asc)

            var todos: [Todo] = []
            for row in try database.prepare(query) {
                let createdDate = Date(timeIntervalSince1970: TimeInterval(row[created]) / 1000.0)
                let dueDate = row[due].map { Date(timeIntervalSince1970: TimeInterval($0) / 1000.0) }

                let todo = Todo(
                    id: row[id],
                    created: createdDate,
                    text: row[text],
                    comment: row[comment],
                    completed: row[completed],
                    due: dueDate,
                    priority: Int(row[priority])
                )
                todos.append(todo)
            }

            return todos
        } catch {
            print("Error fetching due todos: \(error)")
            return []
        }
    }

    // Mark a todo as completed
    func markTodoAsCompleted(id todoId: Int64) {
        guard let database = db else {
            print("Database connection not available")
            return
        }

        do {
            let todo = todoTable.filter(id == todoId)
            try database.run(todo.update(completed <- "Y"))
            print("Marked todo \(todoId) as completed")
        } catch {
            print("Error marking todo as completed: \(error)")
        }
    }
}
