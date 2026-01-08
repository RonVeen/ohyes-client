//
//  Config.swift
//  OhYesClient
//
//  Configuration management for database location and other settings
//

import Foundation

//
//  Config.swift
//  OhYesClient
//
//  Configuration management using Java properties file format
//

import Foundation

struct AppConfig {
    var databasePath: String
    var defaultDueTime: String

    static let `default` = AppConfig(
        databasePath: "/Users/ron/sources/ohyes/target/todo.db",
        defaultDueTime: "09:00"
    )
}

class ConfigManager {
    static let shared = ConfigManager()

    private let configFileName = "ohyes.properties"
    private var configFileURL: URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(configFileName)
    }

    private init() {}

    func loadConfig() -> AppConfig {
        guard FileManager.default.fileExists(atPath: configFileURL.path) else {
            // If config doesn't exist, create default
            let defaultConfig = AppConfig.default
            saveConfig(defaultConfig)
            return defaultConfig
        }

        do {
            let content = try String(contentsOf: configFileURL, encoding: .utf8)
            var config = AppConfig.default
            
            let lines = content.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty || trimmed.hasPrefix("#") || trimmed.hasPrefix("!") {
                    continue
                }
                
                let parts = trimmed.split(separator: "=", maxSplits: 1).map(String.init)
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    switch key {
                    case "database.path":
                        config.databasePath = value
                    case "default.due.time":
                        config.defaultDueTime = value
                    default:
                        break
                    }
                }
            }
            return config
        } catch {
            print("Error loading config: \(error). Using default config.")
            return AppConfig.default
        }
    }

    func saveConfig(_ config: AppConfig) {
        // Read existing lines to preserve comments/other keys if possible (simple implementation overwrites for now)
        // A robust implementation would update in place, but for this scope, rewriting is acceptable 
        // as long as we only manage these two keys.
        // Let's try to preserve other content by reading first.
        
        var existingLines: [String] = []
        if let content = try? String(contentsOf: configFileURL, encoding: .utf8) {
             existingLines = content.components(separatedBy: .newlines)
        }
        
        var newLines: [String] = []
        var foundDb = false
        var foundTime = false
        
        if existingLines.isEmpty {
            // New file
            newLines.append("# OhYes Client Configuration")
            newLines.append("database.path=\(config.databasePath)")
            newLines.append("default.due.time=\(config.defaultDueTime)")
        } else {
            for line in existingLines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("database.path=") || trimmed.hasPrefix("database.path =") {
                    newLines.append("database.path=\(config.databasePath)")
                    foundDb = true
                } else if trimmed.hasPrefix("default.due.time=") || trimmed.hasPrefix("default.due.time =") {
                    newLines.append("default.due.time=\(config.defaultDueTime)")
                    foundTime = true
                } else {
                    newLines.append(line)
                }
            }
            
            if !foundDb {
                newLines.append("database.path=\(config.databasePath)")
            }
            if !foundTime {
                newLines.append("default.due.time=\(config.defaultDueTime)")
            }
        }
        
        let newContent = newLines.joined(separator: "\n")
        
        do {
            try newContent.write(to: configFileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving config: \(error)")
        }
    }

    func expandedDatabasePath() -> String {
        let config = loadConfig()
        return NSString(string: config.databasePath).expandingTildeInPath
    }
}
