import XCTestDynamicOverlay

extension Permissions {
    static let previewValue: Permissions = .init(
        authorizationRequestStatus: { .requested },
        requestAuthorization: {}
    )

    static let testValue: Permissions = .init()
}
