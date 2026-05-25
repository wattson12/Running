import XCTestDynamicOverlay

extension Support {
    static let previewValue: Support = .init(
        isHealthKitDataAvailable: { true }
    )

    static let testValue: Support = .init()
}
