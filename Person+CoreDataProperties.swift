//
//  Person+CoreDataProperties.swift
//  coretests
//
//  Created by Victor on 19.10.2024.
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
    public func getTotalWineCount()-> Int16{
        var sum: Int16 = 0
        let collection = itemsArray
        if (collection.count == 0) {
            return 0
        }
        for i in 0...collection.count-1 {
            sum = sum + (collection[i].quantity)
        }
        return sum;
    }
    public func getTotalDrank()-> Int16{
        var sum: Int16 = 0
        let collection = itemsArray
        if (collection.count == 0) {
            return 0
        }
        for i in 0...collection.count-1 {
            sum = sum + collection[i].drank
        }
        return sum;
    }

    public func getArray(FilterType:String,FilterString:String,SortType:String,WineType:String)->[Item] {
        var Arr: [Item] = []
        let collection = itemsArray
        let searchStringLength = FilterString.count
        
        
        if FilterString == "" {
            if (WineType == "Any") {
                Arr = collection
            }
            else {
                for i in 0...collection.count-1 {
                    if (WineType == collection[i].wrappedType) {
                        Arr.append(collection[i])
                    }

                }

            }
                        
        }
        
        
        else if (FilterType == "Name") {
            for i in 0...collection.count-1 {
                if (String(collection[i].wrappedName.prefix(searchStringLength)).uppercased() == FilterString.uppercased() && (WineType == collection[i].wrappedType || WineType == "Any")) {
                    Arr.append(collection[i])
                }
            }
        }
        else if (FilterType == "Domain") {
            for i in 0...collection.count-1 {
                if (String(collection[i].wrappedDomain.prefix(searchStringLength)).uppercased() == FilterString.uppercased() && (WineType == collection[i].wrappedType || WineType == "Any")) {
                    Arr.append(collection[i])
                }
            }

        }
        else if (FilterType == "Creator") {
            for i in 0...collection.count-1 {
                if (String(collection[i].wrappedCreator.prefix(searchStringLength)).uppercased() == FilterString.uppercased() && (WineType == collection[i].wrappedType || WineType == "Any")) {
                    Arr.append(collection[i])
                }
            }

        }
        
        
        
        if (SortType == "NameD") {
            return sortNameDescending(arr: &Arr)
        }
        else if (SortType == "NameA") {
            return sortNameDescending(arr: &Arr).reversed()
        }
        else if (SortType == "CreatorD") {
            return sortCreatorDescending(arr: &Arr)
        }
        else if (SortType == "CreatorA") {
            return sortCreatorDescending(arr: &Arr).reversed()
        }
        else if (SortType == "DomainD") {
            return sortDomainDescending(arr: &Arr)
        }
        else if (SortType == "DomainA") {
            return sortDomainDescending(arr: &Arr).reversed()
        }
        
        
        
        
        return Arr
    }
    public func sortNameDescending(arr: inout [Item])->[Item]{
        if (arr.count <= 1) {
            return arr;
        }
        var i = -1;
        var j = 0;
        let p = arr.count-1;
        while (j != p) {
            if (arr[j].wrappedName < arr[p].wrappedName) {
                i+=1;
                let temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
            j+=1;
        }
        i+=1;
        let temp = arr[i];
        arr[i] = arr[p];
        arr[p] = temp;
        var tt1 = Array(arr[0..<i])
        var arr1 = sortNameDescending(arr:&tt1)
        var tt2 = Array(arr[i+1..<arr.count])
        let arr2 = sortNameDescending(arr:&tt2)
        arr1.append(arr[i])
        arr1.append(contentsOf: arr2)
        return arr1;
    }
        
    public func sortCreatorDescending(arr: inout [Item])->[Item]{
        if (arr.count <= 1) {
            return arr;
        }
        var i = -1;
        var j = 0;
        let p = arr.count-1;
        while (j != p) {
            if (arr[j].wrappedCreator < arr[p].wrappedCreator) {
                i+=1;
                let temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
            j+=1;
        }
        i+=1;
        let temp = arr[i];
        arr[i] = arr[p];
        arr[p] = temp;
        var tt1 = Array(arr[0..<i])
        var arr1 = sortNameDescending(arr:&tt1)
        var tt2 = Array(arr[i+1..<arr.count])
        let arr2 = sortNameDescending(arr:&tt2)
        arr1.append(arr[i])
        arr1.append(contentsOf: arr2)
        return arr1;
    }
    public func sortDomainDescending(arr: inout [Item])->[Item]{
        if (arr.count <= 1) {
            return arr;
        }
        var i = -1;
        var j = 0;
        let p = arr.count-1;
        while (j != p) {
            if (arr[j].wrappedDomain < arr[p].wrappedDomain) {
                i+=1;
                let temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
            j+=1;
        }
        i+=1;
        let temp = arr[i];
        arr[i] = arr[p];
        arr[p] = temp;
        var tt1 = Array(arr[0..<i])
        var arr1 = sortNameDescending(arr:&tt1)
        var tt2 = Array(arr[i+1..<arr.count])
        let arr2 = sortNameDescending(arr:&tt2)
        arr1.append(arr[i])
        arr1.append(contentsOf: arr2)
        return arr1;
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
