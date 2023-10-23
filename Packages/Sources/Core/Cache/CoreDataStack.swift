import CoreData
import Foundation

extension NSPersistentContainer {
    static func container(inMemory: Bool) -> NSPersistentContainer {
        let momdName = "Running"

        guard let modelURL = Bundle.module.url(forResource: momdName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }

        let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { _, error in
            if let error {
                fatalError("Unresolved error \(error)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }
}

public struct CoreDataStack {
    var _newContext: () -> NSManagedObjectContext

    init(
        newContext: @escaping () -> NSManagedObjectContext
    ) {
        _newContext = newContext
    }
}

public extension CoreDataStack {
    static func stack(inMemory: Bool) -> Self {
        let container: NSPersistentContainer = .container(inMemory: inMemory)
        return .init(
            newContext: {
                let context = container.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                return context
            }
        )
    }
}

public extension CoreDataStack {
    func performWork<T>(_ work: (NSManagedObjectContext) throws -> T) throws -> T {
        let context = _newContext()

        return try context.performAndWait {
            let result = try work(context)

            if context.hasChanges {
                try context.save()
            }

            return result
        }
    }
}
