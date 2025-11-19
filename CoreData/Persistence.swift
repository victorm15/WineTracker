import CoreData

struct PersistenceController {
	static let shared = PersistenceController()
	
	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext
		// your seed data…
		return result
	}()
	
	let container: NSPersistentContainer
	
	init(inMemory: Bool = false) {
		// 👇 use the new model name here
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
