import CoreData

/// Identifies one combination of search, filter and sort settings for one account.
struct QueryKey: Hashable {
	let owner: NSManagedObjectID
	let filterType: String
	let search: String
	let sortType: String
	let wineType: String
}

/// In-memory query cache with LFU-with-aging eviction.
/// Each lookup ages every entry by 1; a hit adds 3 to that entry's weight.
/// When full, the entry with the lowest weight is evicted.
/// Any write to the collection should call `invalidate()`.
final class QueryCache {
	static let shared = QueryCache()

	private var entries: [QueryKey: (items: [Item], weight: Int)] = [:]
	private let capacity = 5

	private init() {}

	func get(_ key: QueryKey, compute: () -> [Item]) -> [Item] {
		// Age every entry so stale-but-once-popular queries eventually get evicted
		entries = entries.mapValues { (items: $0.items, weight: $0.weight - 1) }

		if let hit = entries[key] {
			entries[key] = (items: hit.items, weight: hit.weight + 3)
			return hit.items
		}

		let items = compute()
		if entries.count >= capacity,
		   let victim = entries.min(by: { $0.value.weight < $1.value.weight })?.key {
			entries.removeValue(forKey: victim)
		}
		entries[key] = (items: items, weight: 3)
		return items
	}

	func invalidate() {
		entries.removeAll()
	}
}
