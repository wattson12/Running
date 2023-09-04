import AppIntents
import Foundation
import Model

enum Period: String, CaseIterable, AppEnum {
    case weekly
    case monthly
    case yearly

    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Goal Period"
    public static var caseDisplayRepresentations: [Period: DisplayRepresentation] = [
        .weekly: "Weekly",
        .monthly: "Monthly",
        .yearly: "Yearly",
    ]

    var model: Goal.Period {
        switch self {
        case .weekly:
            return .weekly
        case .monthly:
            return .monthly
        case .yearly:
            return .yearly
        }
    }
}
