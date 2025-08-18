//
//  LiquidGlass.swift
//  Universal PDF Manager
//

import SwiftUI

enum LiquidGlassMaterial: Equatable {
    case none
    case thin
    case ultraThin
}

struct LiquidGlassEnvironmentKey: EnvironmentKey {
    static let defaultValue: LiquidGlassMaterial = .thin
}

extension EnvironmentValues {
    var liquidGlass: LiquidGlassMaterial {
        get { self[LiquidGlassEnvironmentKey.self] }
        set { self[LiquidGlassEnvironmentKey.self] = newValue }
    }
}

private func isMacOSMajorAtLeast(_ major: Int) -> Bool {
    let v = ProcessInfo.processInfo.operatingSystemVersion
    return v.majorVersion >= major
}

struct LiquidGlassProvider: ViewModifier {
    @AppStorage("settings.useLiquidGlassAuto") private var useLiquidGlassAuto: Bool = true

    func body(content: Content) -> some View {
        content
            .environment(\.liquidGlass, determineMaterial())
    }

    private func determineMaterial() -> LiquidGlassMaterial {
        guard useLiquidGlassAuto else { return .thin }
        // 使用者指定：macOS 26 以上才使用更薄的液態玻璃
        if isMacOSMajorAtLeast(26) {
            return .ultraThin
        } else {
            return .thin
        }
    }
}

extension View {
    func useLiquidGlass() -> some View { modifier(LiquidGlassProvider()) }
    @ViewBuilder
    func liquidGlassBackground(_ material: LiquidGlassMaterial) -> some View {
        switch material {
        case .none:
            self
        case .thin:
            self.background(.thinMaterial)
        case .ultraThin:
            self.background(.ultraThinMaterial)
        }
    }
} 