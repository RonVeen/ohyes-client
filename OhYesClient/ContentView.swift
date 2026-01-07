//
//  ContentView.swift
//  OhYesClient
//
//  Main view displaying messages with newest at the top
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var messageStore: MessageStore

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messageStore.messages) { message in
                            Text(message.text)
                                .textSelection(.enabled)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical, 8)
                    .onChange(of: messageStore.messages.count) { _ in
                        if let firstMessage = messageStore.messages.first {
                            withAnimation {
                                proxy.scrollTo(firstMessage.id, anchor: .top)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 400, minHeight: 300)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MessageStore())
    }
}
