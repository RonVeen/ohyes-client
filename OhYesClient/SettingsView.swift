//
//  SettingsView.swift
//  OhYesClient
//
//  View for application settings/preferences
//

import SwiftUI

struct SettingsView: View {
    @State private var databasePath: String = ""
    @State private var defaultDueTime: String = ""
    @State private var timeErrorMessage: String = ""
    @StateObject private var launchAtLoginManager = LaunchAtLoginManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Launch at Login", isOn: $launchAtLoginManager.isEnabled)
            }
            
            Section(header: Text("Database")) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location of the OhYes SQLite database:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Database Path", text: $databasePath)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true) // Read-only, use browse button
                        
                        Button("Browse...") {
                            selectDatabaseFile()
                        }
                    }
                }
            }
            
            Section(header: Text("Defaults")) {
            
            Section {
                Text("Settings saved to ~/ohyes.properties")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(width: 500, height: 280)
        .onAppear {
            loadCurrentConfig()
        }
    }
    
    private func loadCurrentConfig() {
        let config = ConfigManager.shared.loadConfig()
        databasePath = config.databasePath
        defaultDueTime = config.defaultDueTime
    }
    
    private func validateAndSaveTime(_ time: String) {
        // Strict hh:mm format (00-23):(00-59)
        let timeRegex = "^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
        let timePredicate = NSPredicate(format: "SELF MATCHES %@", timeRegex)
        
        if timePredicate.evaluate(with: time) {
            timeErrorMessage = ""
            saveConfig()
        } else {
            timeErrorMessage = "Invalid format (hh:mm)"
        }
    }
    
    private func selectDatabaseFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.database, .data] // Attempt to filter for db files
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.databasePath = url.path
                saveConfig()
                // Reconnect database specifically when path changes
                DatabaseManager.shared.reconnect()
            }
        }
    }
    
    private func saveConfig() {
        var config = ConfigManager.shared.loadConfig()
        config.databasePath = databasePath
        // Only save time if it's valid, otherwise keep old or don't update?
        // Since we validate before calling saveConfig in onChange, we can trust it?
        // Actually, if validation fails in onChange, we don't call saveConfig.
        // But selectDatabaseFile calls saveConfig. We should ensure we don't save invalid time.
        
        if timeErrorMessage.isEmpty {
            config.defaultDueTime = defaultDueTime
        }
        
        ConfigManager.shared.saveConfig(config)
    }
}
