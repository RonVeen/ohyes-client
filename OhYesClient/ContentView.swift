//
//  ContentView.swift
//  OhYesClient
//
//  Main view displaying messages
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var messageStore: MessageStore
    @State private var showAddTodo = false
    @State private var hudMessage: String? = nil

    var body: some View {
        ZStack {
            Group {
                if messageStore.messages.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("There are currently no notifications")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                } else {
                    List(messageStore.messages) { message in
                        MessageRow(message: message)
                    }
                    .listStyle(.inset)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding()
            
            // HUD Overlay
            if let message = hudMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.black.opacity(0.7)))
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(), value: hudMessage)
            }
        }
        .frame(minWidth: 400, minHeight: 300)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddTodo = true }) {
                    Label("Insert Todo", systemImage: "plus")
                }
                .help("Insert Todo (⌘I)")
            }
        }
        .sheet(isPresented: $showAddTodo) {
            AddTodoView { text, date in
                DatabaseManager.shared.insertTodo(text: text, due: date)
                showHUD(message: "Todo \"\(text)\" added")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("InsertTodo"))) { _ in
            showAddTodo = true
        }
    }
    
    private func showHUD(message: String) {
        hudMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                hudMessage = nil
            }
        }
    }
}

struct MessageRow: View {
    @EnvironmentObject var messageStore: MessageStore
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Priority Indicator
            Circle()
                .fill(priorityColor(message.priority))
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    if let due = message.dueDate {
                        TimelineView(.periodic(from: .now, by: 60)) { context in
                            Text("Due \(timeAgo(due, relativeTo: context.date)) (\(formattedExactTime(due)))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(message.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    messageStore.markAsDone(message)
                }
            }) {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.borderless)
            .help("Mark as Done")
            
            Menu {
                Button("Delay 5 min") {
                    withAnimation {
                        messageStore.snoozeMessage(message, minutes: 5)
                    }
                }
                Button("Delay 30 min") {
                    withAnimation {
                        messageStore.snoozeMessage(message, minutes: 30)
                    }
                }
                Button("Delay 60 min") {
                    withAnimation {
                        messageStore.snoozeMessage(message, minutes: 60)
                    }
                }
            } label: {
                Image(systemName: "clock")
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help("Snooze notification")
        }
        .padding(.vertical, 4)
    }

    private func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 0: return .blue
        case 1...4: return .blue
        case 5...9: return .blue
        default: return .gray
        }
    }

    private func timeAgo(_ date: Date, relativeTo: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: relativeTo)
    }
    
    private func formattedExactTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MessageStore())
    }
}
