import Foundation
import Resources
import SwiftUI

enum TintColorEnvironmentKey: EnvironmentKey {
    static var defaultValue: Color = .init(asset: Asset.blue)
}

public extension EnvironmentValues {
    var tintColor: Color {
        get { self[TintColorEnvironmentKey.self] }
        set { self[TintColorEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func customTint(_ color: Color) -> some View {
        environment(\.tintColor, color)
    }
}
