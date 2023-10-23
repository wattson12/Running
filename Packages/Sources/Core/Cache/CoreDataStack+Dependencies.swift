import Dependencies
import Foundation
import XCTestDynamicOverlay

enum CoreDataStackDependencyKey: DependencyKey {
    static var liveValue: CoreDataStack = .stack(inMemory: false)
    static var previewValue: CoreDataStack = .stack(inMemory: true)
    static var testValue: CoreDataStack = .init(
        newContext: unimplemented("CoreDataStack.newContext")
    )
}

public extension DependencyValues {
    var coreData: CoreDataStack {
        get { self[CoreDataStackDependencyKey.self] }
        set { self[CoreDataStackDependencyKey.self] = newValue }
    }
}
