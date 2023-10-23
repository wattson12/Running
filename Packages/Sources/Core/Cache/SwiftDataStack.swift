import Foundation
import SwiftData

@available(*, deprecated, message: "Use CoreDataStack instead")
public struct SwiftDataStack {
    public var _context: () throws -> ModelContext

    init(
        context: @escaping () throws -> ModelContext
    ) {
        _context = context
    }
}

public extension SwiftDataStack {
    @available(*, deprecated, message: "Use CoreDataStack instead")
    func context() throws -> ModelContext {
        try _context()
    }
}
