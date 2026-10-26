import Foundation
import CoreData

extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged private var email: String?
    @NSManaged private var firstName: String?
    @NSManaged private var lastName: String?
    @NSManaged private var username: String?
    @NSManaged public var items: NSSet?

    public var wrappedUsername: String {
        username ?? "_username_"
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
    /// The account's wines, in no particular order. `wines(matching:)` filters and sorts them.
    var wines: Set<Item> {
        items as? Set<Item> ?? []
    }
    /// Usernames are stored trimmed and lowercased so "Bob" and "bob " are the same account.
    public func setUsername(newUsername: String) {
        username = Person.normalizedUsername(newUsername)
    }

    static func normalizedUsername(_ username: String) -> String {
        username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
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

    /// The wines the query includes, in its order. Views go through `QueryCache`, which calls this on a miss.
    func wines(matching query: WineQuery) -> [Item] {
        wines.filter(query.includes).sorted(by: query.areInIncreasingOrder)
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
