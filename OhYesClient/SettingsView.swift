//
//  SettingsView.swift
//  OhYesClient
//
//  View for application settings/preferences
//

import SwiftUI
import ServiceManagement

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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Default due time for new todos (hh:mm):")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("09:00", text: $defaultDueTime)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .onChange(of: defaultDueTime) { newValue in
                                validateAndSaveTime(newValue)
                            }
                        
                        if !timeErrorMessage.isEmpty {
                            Text(timeErrorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
            
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

class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()
    
    @Published var isEnabled: Bool {
        didSet {
            updateRegistration()
        }
    }
    
    private init() {
        if #available(macOS 13.0, *) {
            self.isEnabled = SMAppService.mainApp.status == .enabled
        } else {
            self.isEnabled = false // Fallback for older macOS not implemented for this sample
        }
    }
    
    private func updateRegistration() {
        guard #available(macOS 13.0, *) else { return }
        
        do {
            if isEnabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                    print("Registered for Launch at Login")
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                    print("Unregistered from Launch at Login")
                }
            }
        } catch {
            print("Failed to update Launch at Login status: \(error)")
            // Revert UI if operation failed
            DispatchQueue.main.async {
                self.isEnabled = SMAppService.mainApp.status == .enabled
            }
        }
    }
}
