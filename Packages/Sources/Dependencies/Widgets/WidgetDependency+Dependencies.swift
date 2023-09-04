import Dependencies
import Foundation
import XCTestDynamicOverlay

enum WidgetDependencyDependencyKey: TestDependencyKey {
    static var testValue: WidgetDependency = .init(
        reloadTimelines: unimplemented("WidgetDependency.reloadTimelines"),
        reloadAllTimelines: unimplemented("WidgetDependency.reloadAllTimelines")
    )

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
