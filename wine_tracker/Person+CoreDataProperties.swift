//
//  Person+CoreDataProperties.swift
//  coretests
//
//  Created by Victor Mauger on 15.07.2024.
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
    @NSManaged public var items: NSSet?
    
    public var wrappedUsername: String {
        username ?? "_username_"
    }
    public var wrappedPassword: String {
        password ?? "_password_"
    }
    public var wrappedFirstName: String {
        firstName ?? "_firstName_"
    }
    public var wrappedLastName: String {
        lastName ?? "_lastName_"
    }
    public var wrappedEmail: String {
        email ?? "_email_"
    }
    public var itemsArray: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
    public func getArray(FilterType:String,FilterString:String,SortType:String)->[Item] {
        var Arr: [Item] = []
        let collection = itemsArray
        if FilterString == "" {
            Arr = collection
        }
        else if (FilterType == "Name") {
            for i in 0...collection.count-1 {
                if (collection[i].wrappedName == FilterString) {
                    Arr.append(collection[i])
                }
            }
        }
        else if (FilterType == "Domain") {
            for i in 0...collection.count-1 {
                if (collection[i].wrappedDomain == FilterString) {
                    Arr.append(collection[i])
                }
            }

        }
        else if (FilterType == "Creator") {
            for i in 0...collection.count-1 {
                if (collection[i].wrappedCreator == FilterString) {
                    Arr.append(collection[i])
                }
            }

        }
        if (SortType == "NameD") {
            return Arr.sorted {
                $0.wrappedName < $1.wrappedName
            }
        }
        else if (SortType == "NameA") {
            return Arr.sorted {
                $0.wrappedName > $1.wrappedName
            }
        }
        return Arr
    }




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
