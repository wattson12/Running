import Foundation

public struct FeatureFlagKey: Equatable {
    let rawValue: String
}

extension FeatureFlagKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}
