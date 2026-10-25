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

    /// Removes this account's password hash and Face ID login. Call when deleting the account.
    func deleteCredentials() {
        PasswordStore.delete(for: accountID)
        BiometricLogin.forget(accountID: accountID)
    }

    /// Case-insensitive match so accounts saved before usernames were lowercased still match.
    private static func usernameRequest(_ username: String) -> NSFetchRequest<Person> {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "username ==[c] %@", normalizedUsername(username))
        return request
    }
}
