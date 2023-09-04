import ComposableArchitecture
import Dependencies
import DependenciesAdditions
import Foundation
import Model
import Resources

extension RunListFeature.State {
    public mutating func refresh() -> Effect<RunListFeature.Action> {
        guard !isLoading else { return .none }

        @Dependency(\.userDefaults) var userDefaults
        @Dependency(\.repository.runningWorkouts) var runningWorkouts

        isLoading = true

        if let cachedRuns = runningWorkouts.allRunningWorkouts.cache() {
            setSections(from: cachedRuns)
        } else if userDefaults.bool(forKey: .initialImportCompleted) != true {
            isInitialImport = true
        }

        return .concatenate(
            .send(.delegate(.runsRefreshed)),
            .run { send in
                do {
                    for try await runs in runningWorkouts.allRunningWorkouts.stream() {
                        await send(._internal(.runsFetched(.success(runs))))
                    }
                } catch {
                    await send(._internal(.runsFetched(.failure(error))))
                }
            }
        )
    }

    mutating func setSections(from runs: [Run]) {
        sections = sections(
            from: runs,
            range: filteredDateRange
        )
    }

    func sections(
        from runs: [Run],
        range: DateRange?
    ) -> [RunSection] {
        @Dependency(\.calendar) var calendar
        @Dependency(\.date) var date
        @Dependency(\.uuid) var uuid

        let runs = runs
            .filter { run in
                guard let range else { return true }
                return run.startDate >= range.start && run.startDate < range.end
            }
            .sorted(by: { $0.startDate > $1.startDate })

        var today: [Run] = []
        var yesterday: [Run] = []
        var everythingElse: [Run] = []

        for run in runs {
            if calendar.isDate(run.startDate, inSameDayAs: date.now) {
                today.append(run)
            } else if let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: date.now), calendar.isDate(run.startDate, inSameDayAs: yesterdayDate) {
                yesterday.append(run)
            } else {
                everythingElse.append(run)
            }
        }

        var currentSectionRuns: [Run] = []
        var otherSections: [RunSection] = []
        var currentDate: Date? = everythingElse.first?.startDate
        for run in everythingElse {
            if let currentDateValue = currentDate, calendar.isDate(run.startDate, equalTo: currentDateValue, toGranularity: .month) {
                currentSectionRuns.append(run)
            } else if let currentDateValue = currentDate {
                let additionalDistance: Measurement<UnitLength>?
                if calendar.isDate(currentDateValue, equalTo: date.now, toGranularity: .month) {
                    additionalDistance = (today + yesterday).distance
                } else {
                    additionalDistance = nil
                }

                let newSection = RunSection(
                    id: uuid(),
                    title: DateFormatter.sectionMonth.string(from: currentDateValue),
                    runs: .init(uniqueElements: currentSectionRuns),
                    additionalDistance: additionalDistance
                )

                otherSections.append(newSection)
                currentSectionRuns = []

                currentSectionRuns.append(run)
                currentDate = run.startDate
            }
        }

        if let currentDateValue = currentDate {
            let newSection = RunSection(
                id: uuid(),
                title: DateFormatter.sectionMonth.string(from: currentDateValue),
                runs: .init(uniqueElements: currentSectionRuns)
            )
            otherSections.append(newSection)
            currentSectionRuns = []
        }

        let namedSections: [RunSection] = [
            .init(
                id: uuid(),
                title: L10n.Runs.List.today,
                runs: .init(uniqueElements: today)
            ),
            .init(
                id: uuid(),
                title: L10n.Runs.List.yesterday,
                runs: .init(uniqueElements: yesterday)
            ),
        ]

        return (namedSections + otherSections)
            .filter { !$0.runs.isEmpty }
    }
}
