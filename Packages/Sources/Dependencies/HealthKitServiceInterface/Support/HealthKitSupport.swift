import DependenciesMacros
import Foundation

@DependencyClient
public struct HealthKitSupport: Sendable {
    public var _isHealthKitDataAvailable: @Sendable () -> Bool = { false }

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
