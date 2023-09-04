import Foundation
import Model

public enum GoalListAction: Equatable {
    case edit
}

public enum GoalListRoute: Equatable {
    case weekly(GoalListAction?)
    case monthly(GoalListAction?)
    case yearly(GoalListAction?)

    var period: Goal.Period {
        switch self {
        case .weekly:
            return .weekly
        case .monthly:
            return .monthly
        case .yearly:
            return .yearly
        }
    }

    var action: GoalListAction? {
        switch self {
        case let .weekly(action):
            return action
        case let .monthly(action):
            return action
        case let .yearly(action):
            return action
        }
    }
}
