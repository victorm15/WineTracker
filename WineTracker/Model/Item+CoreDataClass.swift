import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
	/// Bottle counts are capped at three digits, including totals when wines are combined.
	static let maxBottles: Int16 = 999

	/// Whether both describe the same wine, ignoring case and surrounding spaces.
	func isSameWine(as other: Item) -> Bool {
		matches(name: other.wrappedName, domain: other.wrappedDomain, creator: other.wrappedCreator,
				type: other.wrappedType, isVintage: other.isVintage, editionNumber: other.editionNumber)
	}

	/// Whether this wine has these details, ignoring case and surrounding spaces in the text.
	func matches(name: String, domain: String, creator: String, type: String, isVintage: Bool, editionNumber: Int16) -> Bool {
		func same(_ a: String, _ b: String) -> Bool {
			a.trimmingCharacters(in: .whitespacesAndNewlines)
				.caseInsensitiveCompare(b.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
		}
		return same(wrappedName, name)
			&& same(wrappedDomain, domain)
			&& same(wrappedCreator, creator)
			&& wrappedType == type
			&& self.isVintage == isVintage
			&& self.editionNumber == editionNumber
	}
}

/// The kinds of wine the app tracks. Stored on `Item` as the raw value.
enum WineType: String, CaseIterable, Identifiable {
	case red = "Red Wine"
	case white = "White Wine"
	case champagne = "Champagne"

	var id: Self { self }
}
