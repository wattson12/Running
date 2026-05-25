@testable import App
import Model
import URLRouting
import Testing
import Foundation

@Suite
struct AppRouteTests {
    @Test func routingForWeeklyGoals() throws {
        let url: URL = try #require(URL(string: "running://_/goals/weekly"))
        let route = try appRouter.match(url: url)
        #expect(route == .goals(.weekly(nil)))
    }

    @Test func routingForMonthlyGoals() throws {
        let url: URL = try #require(URL(string: "running://_/goals/monthly"))
        let route = try appRouter.match(url: url)
        #expect(route == .goals(.monthly(nil)))
    }

    @Test func routingForYearlyGoals() throws {
        let url: URL = try #require(URL(string: "running://_/goals/yearly"))
        let route = try appRouter.match(url: url)
        #expect(route == .goals(.yearly(nil)))
    }

    @Test func routingForGoalWithEditAction() throws {
        let url: URL = try #require(URL(string: "running://_/goals/yearly/edit"))
        let route = try appRouter.match(url: url)
        #expect(route == .goals(.yearly(.edit)))
    }

    @Test func routingForRuns() throws {
        let url: URL = try #require(URL(string: "running://_/runs"))
        let route = try appRouter.match(url: url)
        #expect(route ==  .runs)
    }

    @Test func routingForInvalidURL() throws {
        let url: URL = try #require(URL(string: "running://_/invalid"))

        let route = try? appRouter.match(url: url)
        #expect(route == nil)
    }
}
