import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
	/// Bottle counts are capped at three digits, including totals when wines are combined.
	static let maxBottles: Int16 = 999

	/// Whether both describe the same wine, ignoring case and surrounding spaces.
	func isSameWine(as other: Item) -> Bool {
		func same(_ a: String, _ b: String) -> Bool {
			a.trimmingCharacters(in: .whitespacesAndNewlines)
				.caseInsensitiveCompare(b.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
		}
		return same(wrappedName, other.wrappedName)
			&& same(wrappedDomain, other.wrappedDomain)
			&& same(wrappedCreator, other.wrappedCreator)
			&& wrappedType == other.wrappedType
			&& isVintage == other.isVintage
			&& editionNumber == other.editionNumber
	}
}

/// The kinds of wine the app tracks. Stored on `Item` as the raw value.
enum WineType: String, CaseIterable, Identifiable {
	case red = "Red Wine"
	case white = "White Wine"
	case champagne = "Champagne"

	var id: Self { self }
}
