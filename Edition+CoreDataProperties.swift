//
//  Edition+CoreDataProperties.swift
//  coretests
//
//  Created by Victor on 19.10.2024.
//
//

import Foundation
import CoreData


extension Edition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Edition> {
        return NSFetchRequest<Edition>(entityName: "Edition")
    }

    @NSManaged public var isEdition: Bool
    @NSManaged public var number: Int16
    @NSManaged public var wine: Item?

}

extension Edition : Identifiable {

}
