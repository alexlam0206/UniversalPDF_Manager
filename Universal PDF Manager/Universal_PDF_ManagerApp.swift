//
//  Universal_PDF_ManagerApp.swift
//  Universal PDF Manager
//
//  Created by Alex Lam on 18/8/2025.
//

import SwiftUI
import SwiftData

@main
struct Universal_PDF_ManagerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PDFDocumentRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .useLiquidGlass()
        }
        .modelContainer(sharedModelContainer)

        Settings {
            SettingsView()
        }

        MenuBarExtra("Universal PDF Manager", systemImage: "doc.richtext") {
            QuickAddMenu()
        }
    }
}
