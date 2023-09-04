import Foundation
import GoalList
import Model
import URLRouting

enum AppRoute: Equatable {
    case goals(GoalListRoute)
    case runs
}

let actionRouter = OneOf {
    Route(.case(GoalListAction.edit)) {
        Path { "edit" }
    }
}

let goalListRouter = OneOf {
    Route(.case(GoalListRoute.weekly)) {
        Path { "weekly" }
        Optionally { actionRouter }
    }

    Route(.case(GoalListRoute.monthly)) {
        Path { "monthly" }
        Optionally { actionRouter }
    }

    Route(.case(GoalListRoute.yearly)) {
        Path { "yearly" }
        Optionally { actionRouter }
    }
}

let appRouter = OneOf {
    Route(.case(AppRoute.goals)) {
        Path { "goals" }
        goalListRouter
    }

    Route(.case(AppRoute.runs)) {
        Path { "runs" }
    }
}
