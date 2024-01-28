import Foundation

public extension FeatureFlagKey {
    static let showRunDetail: Self = .init(
        rawValue: "show_run_detail",
        defaultValue: true
    )
}
