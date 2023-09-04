import Cache
import Foundation
import Model

extension Model.Goal {
    init(cached: Cache.Goal) {
        self.init(
            period: .init(rawValue: cached.period)!,
            target: cached.target.map { target in
                .init(value: target, unit: .meters)
            }
        )
    }
}
