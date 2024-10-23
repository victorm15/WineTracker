//
//  Item+CoreDataProperties.swift
//  coretests
//
//  Created by Victor on 21.10.2024.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var creator: String?
    @NSManaged public var domain: String?
    @NSManaged public var drank: Int16
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var quantity: Int16
    @NSManaged public var type: String?
    @NSManaged public var edition: Edition?
    @NSManaged public var owner: Person?
    @NSManaged public var storage: Query?

}

extension Item : Identifiable {

}
