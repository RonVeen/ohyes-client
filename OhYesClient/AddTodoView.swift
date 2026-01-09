//
//  AddTodoView.swift
//  OhYesClient
//
//  Dialog to insert a new todo
//

import SwiftUI

struct AddTodoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var text: String = ""
    @State private var dueDate: Date = Date()
    @State private var dueTime: Date = Date()
    @State private var errorMessage: String = ""
    
    var onSave: (String, Date) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(.accentColor)
                Text("New Task")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom, 5)
            
            // Form Fields
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Description", systemImage: "text.alignleft")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    TextField("What needs to be done?", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Date", systemImage: "calendar")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        DatePicker("", selection: $dueDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Time", systemImage: "clock")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        DatePicker("", selection: $dueTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.stepperField)
                    }
                    Spacer()
                }
            }
            
            // Error Message
            if !errorMessage.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(errorMessage)
                }
                .foregroundColor(.red)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
                .transition(.opacity)
            }
            
            Spacer()
            
            // Action Buttons
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Add Task") {
                    validateAndSave()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 450, height: 320)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            setDefaultTime()
        }
    }
    
    private func setDefaultTime() {
        // Set default time from config if available (e.g., 09:00)
        let config = ConfigManager.shared.loadConfig()
        let timeParts = config.defaultDueTime.split(separator: ":").map(String.init)
        if timeParts.count == 2, 
           let hour = Int(timeParts[0]), 
           let minute = Int(timeParts[1]) {
            if let dateWithTime = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) {
                dueTime = dateWithTime
            }
        }
    }
    
    private func validateAndSave() {
        // Combine date and time
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: dueTime)
        
        guard let finalDate = calendar.date(bySettingHour: timeComponents.hour ?? 0, 
                                          minute: timeComponents.minute ?? 0, 
                                          second: 0, 
                                          of: dueDate) else {
            errorMessage = "Invalid date/time"
            return
        }
        
        // Validate
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Description is required"
            return
        }
        
        if finalDate < Date() {
            errorMessage = "Due date cannot be in the past"
            return
        }
        
        onSave(text, finalDate)
        presentationMode.wrappedValue.dismiss()
    }
}
