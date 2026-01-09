//
//  LaunchAtLoginManager.swift
//  OhYesClient
//
//  Manages the "Launch at Login" functionality using ServiceManagement
//

import Foundation
import ServiceManagement

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
