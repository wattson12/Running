@testable import Cache
import SwiftData
import XCTest

final class SwiftDataStackTests: XCTestCase {
    func testStackIsCreatedCorrectly() throws {
        let sut = SwiftDataStack.stack(inMemory: false)
        let context = try sut.context()

        let entities = context.container.schema.entitiesByName
        XCTAssertEqual(entities.keys.sorted(), ["DistanceSample", "Goal", "Location", "Run", "RunDetail"])

        let configuration = try XCTUnwrap(context.container.configurations.first)
        XCTAssertEqual(configuration.isStoredInMemoryOnly, false)
        XCTAssertNil(configuration.cloudKitContainerIdentifier)
    }

    func testStackIsCreatedCorrectlyForInMemory() throws {
        let sut = SwiftDataStack.stack(inMemory: true)
        let context = try sut.context()

        let entities = context.container.schema.entitiesByName
        XCTAssertEqual(entities.keys.sorted(), ["DistanceSample", "Goal", "Location", "Run", "RunDetail"])

        let configuration = try XCTUnwrap(context.container.configurations.first)
        XCTAssertEqual(configuration.isStoredInMemoryOnly, true)
        XCTAssertNil(configuration.cloudKitContainerIdentifier)
    }
}
