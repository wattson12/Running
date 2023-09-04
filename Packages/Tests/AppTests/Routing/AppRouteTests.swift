@testable import App
import Model
import URLRouting
import XCTest

final class AppRouteTests: XCTestCase {
    func testRoutingForWeeklyGoals() throws {
        let url: URL = try XCTUnwrap(URL(string: "running://_/goals/weekly"))
        let route = try appRouter.match(url: url)
        XCTAssertEqual(route, .goals(.weekly(nil)))
    }

    func testRoutingForMonthlyGoals() throws {
        let url: URL = try XCTUnwrap(URL(string: "running://_/goals/monthly"))
        let route = try appRouter.match(url: url)
        XCTAssertEqual(route, .goals(.monthly(nil)))
    }

    func testRoutingForYearlyGoals() throws {
        let url: URL = try XCTUnwrap(URL(string: "running://_/goals/yearly"))
        let route = try appRouter.match(url: url)
        XCTAssertEqual(route, .goals(.yearly(nil)))
    }

    func testRoutingForGoalWithEditAction() throws {
        let url: URL = try XCTUnwrap(URL(string: "running://_/goals/yearly/edit"))
        let route = try appRouter.match(url: url)
        XCTAssertEqual(route, .goals(.yearly(.edit)))
    }

    func testRoutingForRuns() throws {
        let url: URL = try XCTUnwrap(URL(string: "running://_/runs"))
        let route = try appRouter.match(url: url)
        XCTAssertEqual(route, .runs)
    }

    func testRoutingForInvalidURL() throws {
        let url: URL = try XCTUnwrap(URL(string: "running://_/invalid"))

        let route = try? appRouter.match(url: url)
        XCTAssertNil(route)
    }
}
