//
//  Edition+CoreDataProperties.swift
//  coretests
//
//  Created by Victor on 21.10.2024.
//
//

import Foundation
import CoreData


extension Edition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Edition> {
        return NSFetchRequest<Edition>(entityName: "Edition")
    }

    @NSManaged private var isEdition: Bool
    @NSManaged private var number: Int16
    @NSManaged public var wine: Item?
    
    public var wrappedIsEdition: Bool {
        isEdition
    }
    public var wrappedNumber: Int16 {
        number
    }
    public func setIsEdition(newIsEdition: Bool) {
        isEdition = newIsEdition
    }
    public func setNumber(newNumber: Int16) {
        number = newNumber
    }
    
}

extension Edition : Identifiable {

}
