import Foundation
import HealthKit
import Model

extension AuthorizationRequestStatus {
    init(model: HKAuthorizationRequestStatus) {
        switch model {
        case .unknown:
            self = .unknown
        case .shouldRequest:
            self = .shouldRequest
        case .unnecessary:
            self = .requested
        @unknown default:
            self = .unknown
        }
    }
}
