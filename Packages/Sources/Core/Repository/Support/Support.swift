import DependenciesMacros
import Foundation

@DependencyClient
public struct Support: Sendable {
    public var _isHealthKitDataAvailable: @Sendable () -> Bool = { false }

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
