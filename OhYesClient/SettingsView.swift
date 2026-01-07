//
//  SettingsView.swift
//  OhYesClient
//
//  View for application settings/preferences
//

import SwiftUI

struct SettingsView: View {
    @State private var databasePath: String = ""
    
    var body: some View {
        Form {
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
        }
        .padding(20)
        .frame(width: 500, height: 150)
        .onAppear {
            loadCurrentConfig()
        }
    }
    
    private func loadCurrentConfig() {
        let config = ConfigManager.shared.loadConfig()
        databasePath = config.databasePath
    }
    
    private func selectDatabaseFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.database, .data] // Attempt to filter for db files
        
        // If we can't depend on UTType for .db, we can use simple extensions check logic in strict environments
        // But NSOpenPanel handles allowedFileTypes (deprecated) or allowedContentTypes
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                let newPath = url.path
                self.databasePath = newPath
                saveConfig(newPath: newPath)
            }
        }
    }
    
    private func saveConfig(newPath: String) {
        var config = ConfigManager.shared.loadConfig()
        config.databasePath = newPath
        ConfigManager.shared.saveConfig(config)
        
        // Reconnect database
        DatabaseManager.shared.reconnect()
    }
}
