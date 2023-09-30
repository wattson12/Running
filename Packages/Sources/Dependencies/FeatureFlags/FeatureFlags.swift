import Foundation

public struct FeatureFlagKey: Equatable {
    let rawValue: String
}

public struct FeatureFlags: Sendable {
    public var _get: @Sendable (FeatureFlagKey) -> Bool
    public var _set: @Sendable (FeatureFlagKey, Bool) -> Void
}

public extension FeatureFlags {
    subscript(_ key: FeatureFlagKey) -> Bool {
        get { _get(key) }
        set { _set(key, newValue) }
    }
}
