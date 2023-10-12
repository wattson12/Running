import Dependencies
import Foundation
import SwiftData
import XCTestDynamicOverlay

public extension SwiftDataStack {
    static func stack(inMemory: Bool) -> SwiftDataStack {
        .init(
            context: {
                print("__debug", "creating context", Thread.main)
                let container = try ModelContainer(
                    for: Run.self, Goal.self, Location.self, Coordinate.self, DistanceSample.self,
                    configurations: ModelConfiguration(
                        isStoredInMemoryOnly: inMemory,
                        cloudKitDatabase: .none
                    )
                )
                let context = ModelContext(container)
                print("__auto", context.autosaveEnabled)
                context.autosaveEnabled = true
                print("__auto", context.autosaveEnabled)
                return context
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
    var swiftData: SwiftDataStack {
        get { self[SwiftDataStackDependencyKey.self] }
        set { self[SwiftDataStackDependencyKey.self] = newValue }
    }
}
