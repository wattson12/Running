import Foundation

public struct FeatureFlagKey: Sendable {
    public let name: String

    public init(name: String) {
        self.name = "feature_flag." + name
    }
}

extension FeatureFlagKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(name: value)
    }
}
