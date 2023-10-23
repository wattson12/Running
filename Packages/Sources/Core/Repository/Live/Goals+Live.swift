import Cache
import CoreData
import Dependencies
import Foundation
import Model
import SwiftData

extension Goals {
    static func live() -> Self {
        @Dependency(\.swiftData) var swiftData
        @Dependency(\.coreData) var coreData

        return .init(
            goal: { period in
                try .init(
                    entity: Implementation.goal(
                        period: period.rawValue,
                        coreData: coreData
                    )
                )
            },
            updateGoal: { goal in
                let context = try swiftData.context()
                let goalEntity = try Implementation.goal(
                    period: goal.period.rawValue,
                    in: context
                )

                goalEntity.target = goal.target?.converted(to: .meters).value

                try context.save()
            }
        )
    }

    private enum Implementation {
        static func goal(period: String, in context: ModelContext) throws -> Cache.Goal {
            let periodRawValue = period
            let descriptor: FetchDescriptor<Cache.Goal> = FetchDescriptor(
                predicate: #Predicate {
                    $0.period == periodRawValue
                }
            )
            let matchingGoals = try context.fetch(descriptor)

            if let existingGoal = matchingGoals.first {
                return existingGoal
            } else {
                let goal = Cache.Goal(
                    period: period,
                    target: nil
                )
                context.insert(goal)
                try context.save()
                return goal
            }
        }

        static func goal(period: String, coreData: CoreDataStack) throws -> Cache.GoalEntity {
            try coreData.performWork { context in
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
}
