import XCTestDynamicOverlay

extension Support {
    static var previewValue: Support = .init(
        isHealthKitDataAvailable: { true }
    )

    static var testValue: Support = .init(
        isHealthKitDataAvailable: {
            unimplemented("Support.isHealthKitDataAvailable", placeholder: false)
        }
    )
}
