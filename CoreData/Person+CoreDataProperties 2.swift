import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged private var email: String?
    @NSManaged private var firstName: String?
    @NSManaged private var lastName: String?
    @NSManaged private var password: String?
    @NSManaged private var username: String?
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
    public func setUsername(newUsername: String) {
        username = newUsername
    }
    public func setPassword(newPassword: String) {
        password = newPassword
    }
    public func setEmail(newEmail: String) {
        email = newEmail
    }
    public func setFirstName(newFirstName: String) {
        firstName = newFirstName
    }
    public func setLastName(newLastName: String) {
        lastName = newLastName
    }
    
    
    public func getTotalWineCount()-> Int16{
        var sum: Int16 = 0
        let collection = itemsArray
        if (collection.count == 0) {
            return 0
        }
        for i in 0...collection.count-1 {
            sum = sum + (collection[i].wrappedQuantity)
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
            sum = sum + collection[i].wrappedDrank
        }
        return sum;
    }
    /// Returns the filtered and sorted wines, served from the in-memory query cache when possible.
    public func getWines(FilterType: String, FilterString: String, SortType: String, WineType: String, viewContext: NSManagedObjectContext) -> [Item] {
        let key = QueryKey(owner: objectID, filterType: FilterType, search: FilterString, sortType: SortType, wineType: WineType)
        return QueryCache.shared.get(key) {
            getArray(FilterType: FilterType, FilterString: FilterString, SortType: SortType, WineType: WineType)
        }
    }

    /// Filters by wine type and a case-insensitive prefix search, then sorts.
    /// Sort types ending in "A" are ascending (A-Z), ending in "D" descending (Z-A).
    public func getArray(FilterType: String, FilterString: String, SortType: String, WineType: String) -> [Item] {
        let search = FilterString.lowercased()

        let filtered = itemsArray.filter { item in
            guard WineType == "Any" || item.wrappedType == WineType else { return false }
            if search.isEmpty { return true }
            let field: String
            switch FilterType {
            case "Domain": field = item.wrappedDomain
            case "Creator": field = item.wrappedCreator
            default: field = item.wrappedName
            }
            return field.lowercased().hasPrefix(search)
        }

        let sortKey: (Item) -> String
        switch SortType {
        case "CreatorA", "CreatorD": sortKey = { $0.wrappedCreator }
        case "DomainA", "DomainD": sortKey = { $0.wrappedDomain }
        default: sortKey = { $0.wrappedName }
        }
        let ascending = SortType.hasSuffix("A")

        return filtered.sorted { a, b in
            var result = sortKey(a).localizedStandardCompare(sortKey(b))
            if result == .orderedSame {
                // Tie-break on name so the order is deterministic
                result = a.wrappedName.localizedStandardCompare(b.wrappedName)
            }
            return ascending ? result == .orderedAscending : result == .orderedDescending
        }
    }

    /// Call after any change to this account's wines.
    func updateCache(viewContext: NSManagedObjectContext) {
        QueryCache.shared.invalidate()
    }

    func collectionLength()-> Bool {
        return itemsArray.count > 0
    }
    func getMostOwned()->Item{
        var max = itemsArray[0]
        for item in itemsArray {
            if(item.wrappedQuantity + item.wrappedDrank > max.wrappedQuantity + max.wrappedDrank) {
                max = item
            }
        }
        return max
        
        
            
    }
    func getFavoriteOwned()->Item{
        var max = itemsArray[0]
        for item in itemsArray {
            if(item.wrappedDrank > max.wrappedDrank) {
                max = item
            }
        }
        return max
        
    }
    func getBuyOwned()->Item{
        var max = itemsArray[0]
        for item in itemsArray {
            if (item.wrappedQuantity == 0) {
                return item
            }
            if(item.wrappedDrank/item.wrappedQuantity > max.wrappedDrank/max.wrappedQuantity) {
                max = item
            }
        }
        return max

    }
    func getTryOwned()->Item{
        var max = itemsArray[0]
        for item in itemsArray {
            if (item.wrappedDrank == 0) {
                return item
            }
            if(item.wrappedQuantity/item.wrappedDrank > max.wrappedQuantity/max.wrappedDrank) {
                max = item
            }
        }
        return max

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
