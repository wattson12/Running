import Dependencies
import Foundation
import WidgetKit

extension WidgetDependencyDependencyKey: DependencyKey {
    static let liveValue: WidgetDependency = .init(
        reloadTimelines: { kind in
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        },
        reloadAllTimelines: {
            WidgetCenter.shared.reloadAllTimelines()
        }
    )
}
