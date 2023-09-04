import Foundation
import SwiftData

public struct SwiftDataStack {
    public var _context: () throws -> ModelContext

    init(
        context: @escaping () throws -> ModelContext
    ) {
        _context = context
    }
}

public extension SwiftDataStack {
    func context() throws -> ModelContext {
        try _context()
    }
}
