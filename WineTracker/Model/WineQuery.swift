import Foundation
import CoreData

/// One view of the collection: a search on one field, an optional type filter and a sort order.
/// Also identifies the results in the query cache.
struct WineQuery: Hashable {
	enum Field: String, CaseIterable, Identifiable {
		case name = "Name", domain = "Domain", creator = "Creator"

		var id: Self { self }

		func value(of wine: Item) -> String {
			switch self {
			case .name: wine.wrappedName
			case .domain: wine.wrappedDomain
			case .creator: wine.wrappedCreator
			}
		}
	}

	var searchField = Field.name
	/// Matched anywhere in the field, ignoring case and accents. Empty matches every wine.
	var search = ""
	/// nil includes every type.
	var type: WineType?
	var sortField = Field.name
	var ascending = true

	/// Whether the wine passes the type filter and the search.
	func includes(_ wine: Item) -> Bool {
		if let type, wine.wineType != type { return false }
		return search.isEmpty || searchField.value(of: wine).localizedStandardContains(search)
	}

	/// Orders by the sort field, then always A to Z by name, then by vintage or edition, type and
	/// object ID, so no two wines compare equal and the order is the same on every load.
	func areInIncreasingOrder(_ a: Item, _ b: Item) -> Bool {
		var result = sortField.value(of: a).localizedStandardCompare(sortField.value(of: b))
		if !ascending { result = result.reversed }
		if result == .orderedSame { result = a.wrappedName.localizedStandardCompare(b.wrappedName) }
		// Vintages before editions.
		if result == .orderedSame { result = compare(a.isVintage ? 0 : 1, b.isVintage ? 0 : 1) }
		if result == .orderedSame { result = compare(a.editionNumber, b.editionNumber) }
		if result == .orderedSame { result = (a.wineType?.rawValue ?? "").compare(b.wineType?.rawValue ?? "") }
		if result == .orderedSame {
			result = a.objectID.uriRepresentation().absoluteString.compare(b.objectID.uriRepresentation().absoluteString)
		}
		return result == .orderedAscending
	}

	private func compare<T: Comparable>(_ a: T, _ b: T) -> ComparisonResult {
		a < b ? .orderedAscending : a > b ? .orderedDescending : .orderedSame
	}
}

private extension ComparisonResult {
	var reversed: ComparisonResult {
		switch self {
		case .orderedAscending: .orderedDescending
		case .orderedDescending: .orderedAscending
		case .orderedSame: .orderedSame
		}
	}
}
