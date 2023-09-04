import Foundation
import SwiftData

@Model
public class Goal {
    public var period: String
    public var target: Double?

    public init(period: String, target: Double?) {
        self.period = period
        self.target = target
    }

    #warning("this shouldn't be needed but Xcode can't build using .init directly")
    public static func create(
        period: String,
        target: Double?
    ) -> Goal {
        .init(period: period, target: target)
    }
}
