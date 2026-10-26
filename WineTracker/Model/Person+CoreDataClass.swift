import Foundation
import CoreData

@objc(Person)
public class Person: NSManagedObject {

    /// A stable ID for this account that survives username changes; used as the Keychain key
    /// for its password hash. Only permanent once the account has been saved (or given a permanent ID).
    var accountID: String {
        objectID.uriRepresentation().absoluteString
    }

    /// Fetches the account with this username, without loading every account into memory.
    static func withUsername(_ username: String, in context: NSManagedObjectContext) -> Person? {
        let request = usernameRequest(username)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    static func withAccountID(_ accountID: String, in context: NSManagedObjectContext) -> Person? {
        guard let url = URL(string: accountID),
              let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {
            return nil
        }
        return try? context.existingObject(with: objectID) as? Person
    }

    static func isUsernameTaken(_ username: String, in context: NSManagedObjectContext) -> Bool {
        let request = usernameRequest(username)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }

    /// Removes an account's password hash and Face ID login. Call once its deletion has been saved.
    static func deleteCredentials(forAccountID accountID: String) {
        PasswordStore.delete(for: accountID)
        BiometricLogin.forget(accountID: accountID)
    }

    /// Deletes this account and, through the cascade rule, its wines. Its login details are
    /// removed only after the deletion is saved, so a failed save leaves the account usable.
    /// Returns false, with nothing changed, if the save fails.
    func deleteAccount() -> Bool {
        guard let context = managedObjectContext else { return false }
        let id = accountID
        context.delete(self)
        guard context.saveOrRollback() else { return false }
        Person.deleteCredentials(forAccountID: id)
        return true
    }

    /// Moves every wine from `other` into this account, adding bottle counts to wines that are
    /// already here, then deletes `other`. Returns the number of wines moved or combined,
    /// or nil, with nothing changed, if the save fails.
    func absorb(_ other: Person) -> Int? {
        guard let context = managedObjectContext, other != self else { return nil }
        let otherID = other.accountID
        let incoming = other.wines
        // Moved wines are added so later ones still combine with them, as when saving one by one.
        var existing = Array(wines)
        for wine in incoming {
            if let match = existing.first(where: { $0.isSameWine(as: wine) }) {
                match.setQuantity(newQuantity: min(match.wrappedQuantity + wine.wrappedQuantity, Item.maxBottles))
                match.setDrank(newDrank: min(match.wrappedDrank + wine.wrappedDrank, Item.maxBottles))
                if match.storedImageData == nil, let photo = wine.storedImageData {
                    match.setImageData(newImageData: photo)
                }
                context.delete(wine)
            } else {
                wine.owner = self
                existing.append(wine)
            }
        }
        context.delete(other)
        guard context.saveOrRollback() else { return nil }
        Person.deleteCredentials(forAccountID: otherID)
        return incoming.count
    }

    /// Case-insensitive match so accounts saved before usernames were lowercased still match.
    private static func usernameRequest(_ username: String) -> NSFetchRequest<Person> {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "username ==[c] %@", normalizedUsername(username))
        return request
    }
}
