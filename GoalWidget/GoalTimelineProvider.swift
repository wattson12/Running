import AppIntents
import Dependencies
import Foundation
import Model
import Permissions
import Repository
import WidgetKit

public struct GoalTimelineProvider: AppIntentTimelineProvider {
    public func placeholder(in _: Context) -> GoalEntry {
        GoalEntry(
            date: Date(),
            period: .weekly,
            progress: 0.5,
            distance: .init(value: 50, unit: .kilometers),
            target: .init(value: 100, unit: .kilometers),
            missingPermissions: false
        )
    }

    public func snapshot(for configuration: GoalWidgetIntent, in _: Context) async -> GoalEntry {
        GoalEntry(
            date: .now,
            period: configuration.period.model,
            progress: 0.5,
            distance: .init(value: 50, unit: .kilometers),
            target: .init(value: 100, unit: .kilometers),
            missingPermissions: false
        )
    }

    public func timeline(for configuration: GoalWidgetIntent, in context: Context) async -> Timeline<GoalEntry> {
        do {
            let entries: [GoalEntry] = try await withDependencies { dependencyValues in
                #if targetEnvironment(simulator)
                    dependencyValues = .preview
                    dependencyValues.date = .constant(.preview)
                    // Make sure date is using preview value when creating screenshot mock data
                    if ProcessInfo.processInfo.environment["SCREENSHOT_LOCALE"] != nil {
                        dependencyValues.date = .constant(.screenshots)
                        withDependencies {
                            $0.date = .constant(.screenshots)
                        } operation: {
                            dependencyValues.updateForScreenshots()
                        }
                    }
                    dependencyValues.defaultAppStorage = .standard
                #endif
            } operation: {
                try await timelineEntries(for: configuration, in: context)
            }
            return Timeline(entries: entries, policy: .atEnd)
        } catch {
            return .init(entries: [placeholder(in: context)], policy: .atEnd)
        }
    }

    private func timelineEntries(for configuration: GoalWidgetIntent, in _: Context) async throws -> [GoalEntry] {
        @Dependency(\.repository.goals) var goals
        @Dependency(\.repository.runningWorkouts) var runningWorkouts
        @Dependency(\.calendar) var calendar
        @Dependency(\.repository.permissions) var permissions

        var entries: [GoalEntry] = []

        let missingPermissions = try await permissions.authorizationRequestStatus() == .shouldRequest

        // get current goal
        let goal = try goals.goal(
            in: configuration.period.model
        )
        let runs = try runningWorkouts.runs(within: goal)

        let distance = runs.distance
        let target = goal.target
        let progress: Double?
        if let target {
            progress = distance.value / target.converted(to: distance.unit).value
        } else {
            progress = nil
        }
        entries.append(
            .init(
                date: .now,
                period: goal.period,
                progress: progress,
                distance: distance,
                target: target,
                missingPermissions: missingPermissions
            )
        )

        return entries
    }
}

extension Date {
    func endOfWeek(calendar: Calendar) -> Date? {
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)
    }
}

private extension DependencyValues {
    mutating func updateForScreenshots() {
        guard let screenshotLocale = ProcessInfo.processInfo.environment["SCREENSHOT_LOCALE"] else { return }
        let locale = Locale(identifier: screenshotLocale)

        repository.runningWorkouts = .mock(
            runs: .screenshots(unit: locale.primaryUnit)
        )
        repository.goals = .mock(
            goals: [
                .init(period: .weekly, target: .init(value: 50, unit: locale.primaryUnit)),
                .init(period: .monthly, target: nil),
                .init(period: .yearly, target: .init(value: 1000, unit: locale.primaryUnit)),
            ]
        )
        self.locale = locale
    }
}
