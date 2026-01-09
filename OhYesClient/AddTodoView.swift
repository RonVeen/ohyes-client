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
        Form {
            Section(header: Text("New Todo")) {
                TextField("Task Description", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                
                DatePicker("Due Time", selection: $dueTime, displayedComponents: .hourAndMinute)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            HStack {
                Spacer()
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Add") {
                    validateAndSave()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400, height: 250)
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
