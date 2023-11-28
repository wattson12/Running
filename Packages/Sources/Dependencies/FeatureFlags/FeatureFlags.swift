import DependenciesMacros
import Foundation

@DependencyClient
public struct FeatureFlags: Sendable {
    public var _get: @Sendable (FeatureFlagKey) -> Bool = { _ in false }
    public var _set: @Sendable (FeatureFlagKey, Bool) -> Void

    init(
        get: @Sendable @escaping (FeatureFlagKey) -> Bool,
        set: @Sendable @escaping (FeatureFlagKey, Bool) -> Void
    ) {
        _get = get
        _set = set
    }
}

public extension FeatureFlags {
    subscript(_ key: FeatureFlagKey) -> Bool {
        get { _get(key) }
        nonmutating set { _set(key, newValue) }
    }
}
