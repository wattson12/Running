import Foundation
import Resources
import SwiftUI

public extension Goal.Period {
    var tint: Color {
        switch self {
        case .weekly:
            return Color(asset: Asset.blue)
        case .monthly:
            return Color(asset: Asset.purple)
        case .yearly:
            return Color(asset: Asset.green)
        }
    }

    var displayName: String {
        switch self {
        case .weekly:
            return L10n.Goal.Period.Weekly.displayName
        case .monthly:
            return L10n.Goal.Period.Monthly.displayName
        case .yearly:
            return L10n.Goal.Period.Yearly.displayName
        }
    }
}
