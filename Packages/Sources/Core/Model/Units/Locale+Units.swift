import Foundation

public extension UnitLength {
    static func primaryUnit(locale: Locale = .current) -> UnitLength {
        locale.primaryUnit
    }

    static func secondaryUnit(locale: Locale = .current) -> UnitLength {
        locale.secondaryUnit
    }
}

public extension Locale {
    var primaryUnit: UnitLength {
        if measurementSystem == .metric {
            return .kilometers
        } else {
            return .miles
        }
    }

    var secondaryUnit: UnitLength {
        if measurementSystem == .metric {
            return .meters
        } else {
            return .feet
        }
    }
}
