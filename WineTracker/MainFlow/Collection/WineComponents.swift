import SwiftUI

extension Item {
	/// "Vintage 2015" or "Edition 3".
	var editionLabel: String {
		"\(isVintage ? "Vintage" : "Edition") \(String(editionNumber))"
	}
}

/// The wine's photo, or the placeholder, cropped to a rounded square.
struct WineThumbnail: View {
	@ObservedObject var wine: Item
	let size: CGFloat

	var body: some View {
		wine.wrappedImage
			.resizable()
			.scaledToFill()
			.frame(width: size, height: size)
			.background(Color(.tertiarySystemFill))
			.clipShape(RoundedRectangle(cornerRadius: size * 0.2))
			.accessibilityHidden(true)
	}
}

/// A small coloured label for the wine type.
struct WineTypeBadge: View {
	let type: String

	private var color: Color {
		switch WineType(rawValue: type) {
		case .red: Color(red: 0.55, green: 0.05, blue: 0.15)
		case .white: Color(red: 0.75, green: 0.6, blue: 0.15)
		case .champagne: Color(red: 0.6, green: 0.5, blue: 0.3)
		case nil: .secondary
		}
	}

	var body: some View {
		Text(WineType(rawValue: type)?.shortName ?? type)
			.font(.caption2.weight(.semibold))
			.foregroundStyle(color)
			.padding(.horizontal, 6)
			.padding(.vertical, 2)
			.background(color.opacity(0.15), in: Capsule())
	}
}
