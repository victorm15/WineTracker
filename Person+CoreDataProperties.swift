//
//  Person+CoreDataProperties.swift
//  coretests
//
//  Created by Victor on 21.10.2024.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var password: String?
    @NSManaged public var username: String?
    @NSManaged public var cache: NSSet?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for cache
extension Person {

    @objc(addCacheObject:)
    @NSManaged public func addToCache(_ value: Query)

    @objc(removeCacheObject:)
    @NSManaged public func removeFromCache(_ value: Query)

    @objc(addCache:)
    @NSManaged public func addToCache(_ values: NSSet)

    @objc(removeCache:)
    @NSManaged public func removeFromCache(_ values: NSSet)

}

// MARK: Generated accessors for items
extension Person {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension Person : Identifiable {

}
