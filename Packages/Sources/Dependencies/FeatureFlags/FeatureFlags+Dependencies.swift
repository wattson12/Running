import Dependencies
import DependenciesAdditions
import Foundation
import XCTestDynamicOverlay

extension FeatureFlags {
    static func userDefaults(_ defaults: UserDefaults.Dependency) -> FeatureFlags {
        .init(
            get: { key in
                defaults.bool(forKey: key.rawValue) ?? false
            },
            set: { key, newValue in
                defaults.set(newValue, forKey: key.rawValue)
            }
        )
    }
}

enum FeatureFlagsDependencyKey: DependencyKey {
    static var liveValue: FeatureFlags = .userDefaults(.standard)
    static var previewValue: FeatureFlags = .userDefaults(.ephemeral())

    static var testValue: FeatureFlags = .init(
        get: unimplemented("FeatureFlags.get", placeholder: false),
        set: unimplemented("FeatureFlags.set")
    )
}

public extension DependencyValues {
    var featureFlags: FeatureFlags {
        get { self[FeatureFlagsDependencyKey.self] }
        set { self[FeatureFlagsDependencyKey.self] = newValue }
    }
}
