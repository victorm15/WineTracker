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
    public var cacheArray: [Query] {
        let set = cache as? Set<Query> ?? []
        return set.sorted {
            $0.wrappedSortType < $1.wrappedSortType
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
    public func reduceWeights(viewContext:NSManagedObjectContext) {
        if (cacheArray.count >= 1) {
            var min = cacheArray[0]
            for query in cacheArray {
                query.weight -= 1
                if(query.weight < min.weight) {
                    min = query
                }
                
            }
            if (cacheArray.count > 5) {
                viewContext.delete(min)
            }
                
            try? viewContext.save()

        }
        
        
                
    }
    public func getWines(FilterType:String,FilterString:String,SortType:String,WineType:String,viewContext:NSManagedObjectContext) -> [Item] {
        for query in cacheArray {
            if(query.wrappedSortType == SortType && query.wrappedWineType == WineType && query.wrappedFilterType == FilterType && query.wrappedSearchRequest == FilterString) {
                query.weight += 3
                reduceWeights(viewContext: viewContext)
                if (query.itemsArray.count <= 0) {
                    return getArray(FilterType: FilterType, FilterString: FilterString, SortType: SortType, WineType: WineType)
                }
                return query.itemsArray
            }
        }
        let newQuery = Query(context: viewContext)
        newQuery.filterType = FilterType
        newQuery.searchRequest = FilterString
        newQuery.wineType = WineType
        newQuery.sortType = SortType
        newQuery.collection = NSSet(array: getArray(FilterType: FilterType, FilterString: FilterString, SortType: SortType, WineType: WineType))
        newQuery.weight = 3
        newQuery.owner = self
        try? viewContext.save()
        reduceWeights(viewContext: viewContext)
        return newQuery.itemsArray
        
        
        
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
            //newQuery.setCollection(newCollection: sortNameDescending(arr: &Arr))
            //addToCache(newQuery)
            //return newQuery.itemsArray
            return sortNameDescending(arr: &Arr)
        }
        else if (SortType == "NameA") {
            //newQuery.setCollection(newCollection: sortNameDescending(arr: &Arr).reversed())
            //addToCache(newQuery)
            //return newQuery.itemsArray
            return sortNameDescending(arr: &Arr).reversed()
        }
        else if (SortType == "CreatorD") {
            //newQuery.setCollection(newCollection:  sortCreatorDescending(arr: &Arr))
            //addToCache(newQuery)
            //return newQuery.itemsArray
            return sortCreatorDescending(arr: &Arr)
        }
        else if (SortType == "CreatorA") {
            //newQuery.setCollection(newCollection: sortCreatorDescending(arr: &Arr).reversed())
            //addToCache(newQuery)
            //return newQuery.itemsArray
            return sortCreatorDescending(arr: &Arr).reversed()
        }
    
        else if (SortType == "DomainD") {
        
            //newQuery.setCollection(newCollection: sortDomainDescending(arr: &Arr))
            //addToCache(newQuery)
            //return newQuery.itemsArray
            return sortDomainDescending(arr: &Arr)
        
        }
        else if (SortType == "DomainA") {
            //newQuery.setCollection(newCollection: sortDomainDescending(arr: &Arr).reversed())
            //addToCache(newQuery)
            //return newQuery.itemsArray
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
    func updateCache(viewContext:NSManagedObjectContext){
        for query in cacheArray {
            let newQuery = Query(context: viewContext)
            newQuery.filterType = query.wrappedFilterType
            newQuery.sortType = query.wrappedSortType
            newQuery.wineType = query.wrappedWineType
            newQuery.searchRequest = query.wrappedSearchRequest
            if let owner = query.owner {
                newQuery.owner = owner
            }
            newQuery.weight = query.weight
            query.collection = NSSet(array: getArray(FilterType: query.wrappedFilterType, FilterString: query.wrappedSearchRequest, SortType: query.wrappedSortType, WineType: query.wrappedWineType))
            viewContext.delete(query)
            try? viewContext.save()
            
            
            
        }
    }
    func collectionLength()-> Bool {
        return itemsArray.count > 0
    }
    func getMostOwned()->Item{
        var max = itemsArray[0]
        for item in itemsArray {
            if(item.quantity + item.drank > max.quantity + max.drank) {
                max = item
            }
        }
        return max
        
        
            
    }
    func getFavoriteOwned()->Item{
        var max = itemsArray[0]
        for item in itemsArray {
            if(item.drank > max.drank) {
                max = item
            }
        }
        return max
        
    }
    func getBuyOwned()->Item{
        var max = itemsArray[0]
        for item in itemsArray {
            if (item.quantity == 0) {
                return item
            }
            if(item.drank/item.quantity > max.drank/max.quantity) {
                max = item
            }
        }
        return max

    }
    func getTryOwned()->Item{
        var max = itemsArray[0]
        for item in itemsArray {
            if (item.drank == 0) {
                return item
            }
            if(item.quantity/item.drank > max.quantity/max.drank) {
                max = item
            }
        }
        return max

    }

            
        
    


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
