import Foundation

public struct WidgetDependency: Sendable {
    public var _reloadTimelines: @Sendable (String) -> Void
    public var _reloadAllTimelines: @Sendable () -> Void

    public init(
        reloadTimelines: @Sendable @escaping (String) -> Void,
        reloadAllTimelines: @Sendable @escaping () -> Void
    ) {
        _reloadTimelines = reloadTimelines
        _reloadAllTimelines = reloadAllTimelines
    }
}

public extension WidgetDependency {
    func reloadTimelines(ofKind kind: String) {
        _reloadTimelines(kind)
    }

    func reloadAllTimelines() {
        _reloadAllTimelines()
    }
}
