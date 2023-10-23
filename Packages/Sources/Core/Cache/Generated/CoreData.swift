// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable superfluous_disable_command implicit_return
// swiftlint:disable sorted_imports
import CoreData
import Foundation

// swiftlint:disable attributes file_length vertical_whitespace_closing_braces
// swiftlint:disable identifier_name line_length type_body_length

// MARK: - DistanceSampleEntity

public final class DistanceSampleEntity: NSManagedObject {
    public class var entityName: String {
        "DistanceSampleEntity"
    }

    public class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistanceSampleEntity> {
        NSFetchRequest<DistanceSampleEntity>(entityName: entityName)
    }

    @nonobjc public class func makeFetchRequest() -> NSFetchRequest<DistanceSampleEntity> {
        NSFetchRequest<DistanceSampleEntity>(entityName: entityName)
    }

    // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection implicit_getter
    // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection implicit_getter
}

// MARK: - GoalEntity

public final class GoalEntity: NSManagedObject {
    public class var entityName: String {
        "GoalEntity"
    }

    public class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalEntity> {
        NSFetchRequest<GoalEntity>(entityName: entityName)
    }

    @nonobjc public class func makeFetchRequest() -> NSFetchRequest<GoalEntity> {
        NSFetchRequest<GoalEntity>(entityName: entityName)
    }

    // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection implicit_getter
    // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection implicit_getter
}

// MARK: - LocationEntity

public final class LocationEntity: NSManagedObject {
    public class var entityName: String {
        "LocationEntity"
    }

    public class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationEntity> {
        NSFetchRequest<LocationEntity>(entityName: entityName)
    }

    @nonobjc public class func makeFetchRequest() -> NSFetchRequest<LocationEntity> {
        NSFetchRequest<LocationEntity>(entityName: entityName)
    }

    // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection implicit_getter
    // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection implicit_getter
}

// MARK: - RunDetailEntity

public final class RunDetailEntity: NSManagedObject {
    public class var entityName: String {
        "RunDetailEntity"
    }

    public class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RunDetailEntity> {
        NSFetchRequest<RunDetailEntity>(entityName: entityName)
    }

    @nonobjc public class func makeFetchRequest() -> NSFetchRequest<RunDetailEntity> {
        NSFetchRequest<RunDetailEntity>(entityName: entityName)
    }

    // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection implicit_getter
    // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection implicit_getter
}

// MARK: - RunEntity

public final class RunEntity: NSManagedObject {
    public class var entityName: String {
        "RunEntity"
    }

    public class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    }

    @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RunEntity> {
        NSFetchRequest<RunEntity>(entityName: entityName)
    }

    @nonobjc public class func makeFetchRequest() -> NSFetchRequest<RunEntity> {
        NSFetchRequest<RunEntity>(entityName: entityName)
    }

    // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection implicit_getter
    // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection implicit_getter
}

// swiftlint:enable identifier_name line_length type_body_length
