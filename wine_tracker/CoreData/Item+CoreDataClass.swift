import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {

}

/// The kinds of wine the app tracks. Stored on `Item` as the raw value.
enum WineType: String, CaseIterable, Identifiable {
	case red = "Red Wine"
	case white = "White Wine"
	case champagne = "Champagne"

	var id: Self { self }
}
