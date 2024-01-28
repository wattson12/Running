import Foundation

public extension FeatureFlagKey {
    static let history: Self = .init(
        rawValue: "history_feature",
        defaultValue: false
    )
}
