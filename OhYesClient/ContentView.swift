//
//  ContentView.swift
//  OhYesClient
//
//  Main view displaying messages
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var messageStore: MessageStore

    var body: some View {
        List(messageStore.messages) { message in
            MessageRow(message: message)
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

struct MessageRow: View {
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
                        Text("Due \(timeAgo(due))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(message.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 0: return .blue
        case 1...4: return .yellow
        case 5...9: return .red
        default: return .gray
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MessageStore())
    }
}
