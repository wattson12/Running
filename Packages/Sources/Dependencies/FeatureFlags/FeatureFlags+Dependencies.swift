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

    public static func mock(enabled: [FeatureFlagKey]) -> FeatureFlags {
        let enabled: LockIsolated<[FeatureFlagKey]> = .init(enabled)
        return FeatureFlags(
            get: { enabled.value.contains($0) },
            set: { key, value in
                var enabledKeys = enabled.value
                if value, !enabledKeys.contains(key) {
                    enabledKeys.append(key)
                } else if !value {
                    enabledKeys.removeAll(where: { $0 == key })
                }

                let immutableUpdatedValue = enabledKeys
                enabled.setValue(immutableUpdatedValue)
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
