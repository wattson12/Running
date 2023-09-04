import Foundation

public struct HealthKitSupport: Sendable {
    public var _isHealthKitDataAvailable: @Sendable () -> Bool

    public init(
        isHealthKitDataAvailable: @Sendable @escaping () -> Bool
    ) {
        _isHealthKitDataAvailable = isHealthKitDataAvailable
    }
}

public extension HealthKitSupport {
    func isHealthKitDataAvailable() -> Bool {
        _isHealthKitDataAvailable()
    }
}
