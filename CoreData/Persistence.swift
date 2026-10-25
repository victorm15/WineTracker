import CoreData
import SwiftUI

struct PersistenceController {
	static let shared = PersistenceController()

	/// In-memory store with one account and a few wines, for SwiftUI previews.
	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext

		let person = Person(context: viewContext)
		person.setUsername(newUsername: "preview")
		person.setFirstName(newFirstName: "Ada")
		person.setLastName(newLastName: "Lovelace")
		person.setEmail(newEmail: "ada@example.com")

		let wines: [(name: String, domain: String, creator: String, type: WineType, quantity: Int16, drank: Int16, vintage: Int16)] = [
			("Margaux", "Château Margaux", "Paul Pontallier", .red, 6, 2, 2015),
			("Chablis Premier Cru", "Domaine William Fèvre", "Didier Séguier", .white, 3, 1, 2020),
			("Brut Réserve", "Charles Heidsieck", "Cyril Brun", .champagne, 2, 4, 2012),
		]
		for wine in wines {
			let item = Item(context: viewContext)
			item.setName(newName: wine.name)
			item.setDomain(newDomain: wine.domain)
			item.setCreator(newCreator: wine.creator)
			item.setType(newType: wine.type.rawValue)
			item.setQuantity(newQuantity: wine.quantity)
			item.setDrank(newDrank: wine.drank)
			item.owner = person
			let edition = Edition(context: viewContext)
			edition.setIsEdition(newIsEdition: true)
			edition.setNumber(newNumber: wine.vintage)
			edition.wine = item
		}

		do {
			try viewContext.save()
		} catch {
			fatalError("Couldn't seed preview data: \(error)")
		}
		return result
	}()

	/// The account seeded into `preview`.
	static var previewPerson: Person {
		let request = NSFetchRequest<Person>(entityName: "Person")
		request.fetchLimit = 1
		guard let person = try? preview.container.viewContext.fetch(request).first else {
			fatalError("Preview store has no account")
		}
		return person
	}

	let container: NSPersistentContainer

	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "wineModel")

		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}

		container.loadPersistentStores { _, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}

		container.viewContext.automaticallyMergesChangesFromParent = true
	}
}

extension View {
	/// Gives a preview the seeded store and an app state logged in as `previewPerson`.
	func previewEnvironment() -> some View {
		let appState = AppState()
		appState.currentPerson = PersistenceController.previewPerson
		return self
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
			.environmentObject(appState)
	}
}
