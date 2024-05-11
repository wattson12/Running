import ComposableArchitecture
import Foundation

public struct FeatureFlagKey {
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

public extension FeatureFlagKey {
    static let history: Self = "history_feature_enabled"
    static let program: Self = "program_feature_enabled"
    static let runDetail: Self = "run_detail_enabled"
}

public extension PersistenceReaderKey where Value == Bool {
    static func featureFlag(_ key: FeatureFlagKey) -> Self
        where Self == AppStorageKey<Bool>
    {
        AppStorageKey(key.name)
    }
}
