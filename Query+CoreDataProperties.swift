//
//  Query+CoreDataProperties.swift
//  coretests
//
//  Created by Victor on 21.10.2024.
//
//

import Foundation
import CoreData


extension Query {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Query> {
        return NSFetchRequest<Query>(entityName: "Query")
    }

    @NSManaged public var searchRequest: String?
    @NSManaged public var sortType: String?
    @NSManaged public var weight: Int16
    @NSManaged public var wineType: String?
    @NSManaged public var filterType: String?
    @NSManaged public var collection: NSSet?
    @NSManaged public var owner: Person?

}

// MARK: Generated accessors for collection
extension Query {

    @objc(addCollectionObject:)
    @NSManaged public func addToCollection(_ value: Item)

    @objc(removeCollectionObject:)
    @NSManaged public func removeFromCollection(_ value: Item)

    @objc(addCollection:)
    @NSManaged public func addToCollection(_ values: NSSet)

    @objc(removeCollection:)
    @NSManaged public func removeFromCollection(_ values: NSSet)

}

extension Query : Identifiable {

}
