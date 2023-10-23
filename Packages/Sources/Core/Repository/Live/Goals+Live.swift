import Cache
import CoreData
import Dependencies
import Foundation
import Model
import SwiftData

extension Goals {
    static func live() -> Self {
        @Dependency(\.coreData) var coreData

        return .init(
            goal: { period in
                try coreData.performWork { context in
                    try .init(
                        entity: Implementation.goal(
                            period: period.rawValue,
                            context: context
                        )
                    )
                }
            },
            updateGoal: { goal in
                try coreData.performWork { context in
                    let goalEntity = try Implementation.goal(
                        period: goal.period.rawValue,
                        context: context
                    )

                    goalEntity.target = goal.target?.converted(to: .meters).value

                    try context.save()
                }
            }
        )
    }

    private enum Implementation {
        static func goal(
            period: String,
            context: NSManagedObjectContext
        ) throws -> Cache.GoalEntity {
            let fetchRequest = Cache.GoalEntity.makeFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "period == %@", period)
            let matchingGoals = try context.fetch(fetchRequest)

            if let existingGoal = matchingGoals.first {
                return existingGoal
            } else {
                let goal = Cache.GoalEntity(context: context)
                goal.period = period
                goal.target = nil
                try context.save()
                return goal
            }
        }
    }
}
