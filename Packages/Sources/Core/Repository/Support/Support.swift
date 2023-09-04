import Foundation

public struct Support: Sendable {
    public var _isHealthKitDataAvailable: @Sendable () -> Bool

    public init(
        isHealthKitDataAvailable: @Sendable @escaping () -> Bool
    ) {
        _isHealthKitDataAvailable = isHealthKitDataAvailable
    }
}

public extension Support {
    func isHealthKitDataAvailable() -> Bool {
        _isHealthKitDataAvailable()
    }
}
