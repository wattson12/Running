import ComposableArchitecture
import Foundation

public extension PersistenceReaderKey where Value == Bool {
    static func featureFlag(_ key: FeatureFlagKey) -> Self
        where Self == AppStorageKey<Bool>
    {
        AppStorageKey(key.name)
    }
}
