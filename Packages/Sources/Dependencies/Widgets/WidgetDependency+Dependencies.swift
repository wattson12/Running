import Dependencies
import Foundation
import XCTestDynamicOverlay

enum WidgetDependencyDependencyKey: TestDependencyKey {
    static let testValue: WidgetDependency = .init()

    static let previewValue: WidgetDependency = .init(
        reloadTimelines: { _ in },
        reloadAllTimelines: {}
    )
}

public extension DependencyValues {
    var widget: WidgetDependency {
        get { self[WidgetDependencyDependencyKey.self] }
        set { self[WidgetDependencyDependencyKey.self] = newValue }
    }
}
