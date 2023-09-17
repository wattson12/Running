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
}
