//
//  SettingsView.swift
//  Universal PDF Manager
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("settings.useLiquidGlassAuto") private var useLiquidGlassAuto: Bool = true
    @AppStorage("settings.ocrLanguages") private var ocrLanguages: String = "en-US,zh-Hant,zh-Hans"
    @AppStorage("settings.renameFormat") private var renameFormat: String = "{title}_{year}_{vendor}"
    @AppStorage("settings.enableSpotlightIndex") private var enableSpotlightIndex: Bool = false

    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem { Label("General", systemImage: "gear") }
            OCRSettings()
                .tabItem { Label("OCR", systemImage: "text.viewfinder") }
            FilingSettings()
                .tabItem { Label("Filing", systemImage: "folder") }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 360)
    }

    @ViewBuilder
    private func GeneralSettings() -> some View {
        Form {
            Toggle("Use Liquid Glass when supported", isOn: $useLiquidGlassAuto)
            Toggle("Enable Spotlight indexing", isOn: $enableSpotlightIndex)
        }
        .groupedFormStyleIfAvailable()
    }

    @ViewBuilder
    private func OCRSettings() -> some View {
        Form {
            Text("Preferred OCR Languages (BCP-47, comma separated)")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("en-US,zh-Hant,zh-Hans", text: $ocrLanguages)
        }
        .groupedFormStyleIfAvailable()
    }

    @ViewBuilder
    private func FilingSettings() -> some View {
        Form {
            Text("Auto-rename format")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("{title}_{year}_{vendor}", text: $renameFormat)
            Text("Placeholders: {title} {author} {year} {vendor} {amount}")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .groupedFormStyleIfAvailable()
    }
}

private extension View {
    @ViewBuilder
    func groupedFormStyleIfAvailable() -> some View {
        if #available(macOS 13.0, *) {
            self.formStyle(.grouped)
        } else {
            self
        }
    }
} 