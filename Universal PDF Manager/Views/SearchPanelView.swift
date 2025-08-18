//
//  SearchPanelView.swift
//  Universal PDF Manager
//

import SwiftUI

struct SearchPanelView: View {
    @ObservedObject var bridge: PDFBridge
    @State private var query: String = ""
    @State private var caseSensitive: Bool = false
    @State private var count: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Search text", text: $query)
                Toggle("Aa", isOn: $caseSensitive).toggleStyle(.switch)
                Button("Find") { count = bridge.search(query, caseSensitive: caseSensitive) }
            }
            .padding(.bottom, 4)
            Text("Found: \(count)").font(.caption).foregroundStyle(.secondary)
        }
        .padding(8)
        .frame(minWidth: 260)
    }
} 