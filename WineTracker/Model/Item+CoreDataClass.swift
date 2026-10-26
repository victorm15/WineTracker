import Foundation
import CoreData
import ImageIO
import SwiftUI

@objc(Item)
public class Item: NSManagedObject {
	/// Bottle counts are capped at three digits, including totals when wines are combined.
	static let maxBottles: Int16 = 999

	/// The decoded thumbnail and the photo data it was made from, so a new photo replaces it.
	private var thumbnailCache: (data: Data, image: UIImage)?

	/// The photo shrunk to list size, or the placeholder. Decoded once rather than on every redraw.
	var thumbnail: Image {
		guard let data = storedImageData else { return Image("Image") }
		if let thumbnailCache, thumbnailCache.data == data {
			return Image(uiImage: thumbnailCache.image)
		}
		guard let image = Self.downsample(data, maxPixelSize: 256) else { return Image("Image") }
		thumbnailCache = (data, image)
		return Image(uiImage: image)
	}

	/// Decodes the image straight to the smaller size, without decoding it at full size first.
	private static func downsample(_ data: Data, maxPixelSize: Int) -> UIImage? {
		guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary) else {
			return nil
		}
		let options = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceShouldCacheImmediately: true,
			kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
		] as CFDictionary
		return CGImageSourceCreateThumbnailAtIndex(source, 0, options).map { UIImage(cgImage: $0) }
	}

	/// Whether both describe the same wine, ignoring case and surrounding spaces.
	func isSameWine(as other: Item) -> Bool {
		matches(name: other.wrappedName, domain: other.wrappedDomain, creator: other.wrappedCreator,
				type: other.wineType, isVintage: other.isVintage, editionNumber: other.editionNumber)
	}

	/// Whether this wine has these details, ignoring case and surrounding spaces in the text.
	func matches(name: String, domain: String, creator: String, type: WineType?, isVintage: Bool, editionNumber: Int16) -> Bool {
		func same(_ a: String, _ b: String) -> Bool {
			a.trimmingCharacters(in: .whitespacesAndNewlines)
				.caseInsensitiveCompare(b.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
		}
		return same(wrappedName, name)
			&& same(wrappedDomain, domain)
			&& same(wrappedCreator, creator)
			&& wineType == type
			&& self.isVintage == isVintage
			&& self.editionNumber == editionNumber
	}
}

/// The kinds of wine the app tracks. The raw values are the keys stored on `Item`, so they must never
/// change, even if a name on screen does: show `name` or `shortName` instead.
enum WineType: String, CaseIterable, Identifiable {
	case red = "Red Wine"
	case white = "White Wine"
	case champagne = "Champagne"

	var id: Self { self }

	var name: String {
		switch self {
		case .red: "Red Wine"
		case .white: "White Wine"
		case .champagne: "Champagne"
		}
	}

	/// Fits a segmented control or a badge.
	var shortName: String {
		switch self {
		case .red: "Red"
		case .white: "White"
		case .champagne: "Champagne"
		}
	}
}
