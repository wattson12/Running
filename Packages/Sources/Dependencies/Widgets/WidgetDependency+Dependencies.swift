import Dependencies
import Foundation
import XCTestDynamicOverlay

enum WidgetDependencyDependencyKey: TestDependencyKey {
    static var testValue: WidgetDependency = .init()

    static var previewValue: WidgetDependency = .init(
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
