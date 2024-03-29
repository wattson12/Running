import Foundation

public struct FeatureFlagKey: Equatable {
    let rawValue: String
    let defaultValue: Bool
}

extension FeatureFlagKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value, defaultValue: false)
    }
}
