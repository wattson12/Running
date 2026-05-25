import ComposableArchitecture
import Foundation

public extension SharedReaderKey where Value == Bool {
    static func featureFlag(_ key: FeatureFlagKey) -> Self
        where Self == AppStorageKey<Bool>
    {
        .appStorage(key.name)
    }
}
