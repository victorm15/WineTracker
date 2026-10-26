import CoreData
import Observation

/// The results of the last few collection queries for one logged-in account, kept in memory only.
///
/// Eviction is LFU with aging: every lookup ages all entries by 1 and a hit adds 3; when full, the
/// entry with the lowest weight goes (the least recently used one on a tie). Aging is tracked with
/// one clock rather than by changing every entry: an entry's weight is its `score` minus `clock`.
///
/// After each save, the cached lists are updated in place: changed and deleted wines are taken out,
/// and wines that still belong are put back at their sorted place. Nothing is filtered or sorted again.
@Observable
final class QueryCache: NSObject {
	private struct Entry {
		var wines: [Item]
		var score: Int
		var lastUsed: Int
	}

	/// Increased after a save has been applied, so views can show the updated lists.
	private(set) var revision = 0

	@ObservationIgnored private let person: Person
	@ObservationIgnored private var entries: [WineQuery: Entry] = [:]
	@ObservationIgnored private var clock = 0
	@ObservationIgnored private let capacity = 5

	init(person: Person) {
		self.person = person
		super.init()
		// Loads all of the account's wines in one query. Otherwise `person.wines` fetches only their
		// IDs, and each wine is then loaded on its own the first time it's read.
		let request = Person.fetchRequest()
		request.predicate = NSPredicate(format: "self == %@", person)
		request.relationshipKeyPathsForPrefetching = ["items"]
		_ = try? person.managedObjectContext?.fetch(request)
		// Removed automatically when the cache is freed, on logout or account switch.
		NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)),
											   name: .NSManagedObjectContextDidSave, object: person.managedObjectContext)
	}

	/// The query's wines, counting as a use of the query.
	func wines(matching query: WineQuery) -> [Item] {
		let key = Self.key(for: query)
		clock += 1
		if var entry = entries[key] {
			entry.score += 3
			entry.lastUsed = clock
			entries[key] = entry
			return entry.wines
		}
		let wines = person.wines(matching: key)
		if entries.count >= capacity,
		   let victim = entries.min(by: { ($0.value.score, $0.value.lastUsed) < ($1.value.score, $1.value.lastUsed) })?.key {
			entries.removeValue(forKey: victim)
		}
		entries[key] = Entry(wines: wines, score: clock + 3, lastUsed: clock)
		return wines
	}

	/// The query's wines without counting as a use; for showing a list again after a save.
	func peek(_ query: WineQuery) -> [Item] {
		entries[Self.key(for: query)]?.wines ?? wines(matching: query)
	}

	/// Searches ignore case and accents, so "Mar", "mar" and "már" share one entry.
	private static func key(for query: WineQuery) -> WineQuery {
		var key = query
		key.search = query.search.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
		return key
	}

	@objc private func contextDidSave(_ notification: Notification) {
		func wines(_ key: String) -> Set<Item> {
			Set((notification.userInfo?[key] as? Set<NSManagedObject> ?? []).compactMap { $0 as? Item })
		}
		let changed = wines(NSInsertedObjectsKey).union(wines(NSUpdatedObjectsKey))
		let removed = changed.union(wines(NSDeletedObjectsKey))
		guard !removed.isEmpty else { return }

		// Only wines that are this account's now go back in; moved-away and deleted ones stay out.
		let kept = changed.filter { !$0.isDeleted && $0.owner == person }
		for key in Array(entries.keys) {
			var list = entries[key]!.wines
			list.removeAll { removed.contains($0) }
			for wine in kept where key.includes(wine) {
				list.insert(wine, at: insertionIndex(of: wine, in: list, for: key))
			}
			entries[key]!.wines = list
		}
		revision += 1
	}

	/// Where the wine goes in a list already in the query's order, found by binary search.
	private func insertionIndex(of wine: Item, in list: [Item], for query: WineQuery) -> Int {
		var low = 0, high = list.count
		while low < high {
			let middle = (low + high) / 2
			if query.areInIncreasingOrder(list[middle], wine) {
				low = middle + 1
			} else {
				high = middle
			}
		}
		return low
	}
}
