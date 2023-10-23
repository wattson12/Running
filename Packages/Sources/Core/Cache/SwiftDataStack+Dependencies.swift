import Dependencies
import Foundation
import SwiftData
import XCTestDynamicOverlay

public extension SwiftDataStack {
    @available(*, deprecated, message: "Use CoreDataStack instead")
    static func stack(inMemory: Bool) -> SwiftDataStack {
        .init(
            context: {
                let container = try ModelContainer(
                    for: Run.self, RunDetail.self, Goal.self,
                    configurations: ModelConfiguration(
                        isStoredInMemoryOnly: inMemory,
                        cloudKitDatabase: .none
                    )
                )
                return ModelContext(container)
            }
        )
    }
}

enum SwiftDataStackDependencyKey: DependencyKey {
    static var liveValue: SwiftDataStack = .stack(inMemory: false)
    static var previewValue: SwiftDataStack = .stack(inMemory: true)
    static var testValue: SwiftDataStack = .init(
        context: unimplemented("SwiftDataStack.context")
    )
}

public extension DependencyValues {
    @available(*, deprecated, message: "Use CoreDataStack instead")
    var swiftData: SwiftDataStack {
        get { self[SwiftDataStackDependencyKey.self] }
        set { self[SwiftDataStackDependencyKey.self] = newValue }
    }
}
