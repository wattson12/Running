import Dependencies
import Foundation
import XCTestDynamicOverlay

enum CoreDataStackDependencyKey: DependencyKey {
    static let liveValue: CoreDataStack = .stack(inMemory: false)
    static let previewValue: CoreDataStack = .stack(inMemory: true)
    static let testValue: CoreDataStack = .init()
}

public extension DependencyValues {
    var coreData: CoreDataStack {
        get { self[CoreDataStackDependencyKey.self] }
        set { self[CoreDataStackDependencyKey.self] = newValue }
    }
}
