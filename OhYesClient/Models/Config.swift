//
//  Config.swift
//  OhYesClient
//
//  Configuration management for database location and other settings
//

import Foundation

struct AppConfig: Codable {
    var databasePath: String

    static let `default` = AppConfig(
        databasePath: "/Users/ron/sources/ohyes/target/todo.db"
    )
}

class ConfigManager {
    static let shared = ConfigManager()

    private let configFileName = "config.json"
    private var configFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupport.appendingPathComponent("OhYesClient")

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)

        return appDirectory.appendingPathComponent(configFileName)
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
            let data = try Data(contentsOf: configFileURL)
            let config = try JSONDecoder().decode(AppConfig.self, from: data)
            return config
        } catch {
            print("Error loading config: \(error). Using default config.")
            return AppConfig.default
        }
    }

    func saveConfig(_ config: AppConfig) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(config)
            try data.write(to: configFileURL)
        } catch {
            print("Error saving config: \(error)")
        }
    }

    func expandedDatabasePath() -> String {
        let config = loadConfig()
        return NSString(string: config.databasePath).expandingTildeInPath
    }
}
