import XCTestDynamicOverlay

extension Permissions {
    static var previewValue: Permissions = .init(
        authorizationRequestStatus: { .requested },
        requestAuthorization: {}
    )

    static var testValue: Permissions = .init(
        authorizationRequestStatus: unimplemented("Permissions.authorizationRequestStatus", placeholder: .unknown),
        requestAuthorization: unimplemented("Permissions.requestAuthorization")
    )
}
