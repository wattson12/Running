import Foundation
import SwiftData

@Model
public class Run {
    public let id: UUID
    public var startDate: Date
    public var distance: Double
    public var duration: Double
    public var detail: RunDetail?

    public init(
        id: UUID,
        startDate: Date,
        distance: Double,
        duration: Double,
        detail: RunDetail?
    ) {
        self.id = id
        self.startDate = startDate
        self.distance = distance
        self.duration = duration
        self.detail = detail
    }
}
