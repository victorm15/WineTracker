import SwiftUI
import PhotosUI

// Form pieces shared by the add and edit wine pages.

/// What's entered in the Add Wine or Edit Wine form, with the checks both pages share.
struct WineDraft: Equatable {
	/// The checks a draft can fail, in form order.
	enum Problem {
		case details, edition
	}

	var name = ""
	var domain = ""
	var creator = ""
	var type = WineType.red
	/// Vintage: `editionNumber` is a vintage year. Edition: it's an edition number.
	var isVintage = true
	var editionNumber = ""
	var quantity = "1"
	var drank = "0"

	init() {}

	/// The wine's current details, for editing.
	init(_ wine: Item) {
		name = wine.wrappedName
		domain = wine.wrappedDomain
		creator = wine.wrappedCreator
		type = wine.wineType ?? .red
		isVintage = wine.isVintage
		editionNumber = String(wine.editionNumber)
		quantity = String(wine.wrappedQuantity)
		drank = String(wine.wrappedDrank)
	}

	static var vintageYears: ClosedRange<Int16> {
		1800...Int16(Calendar.current.component(.year, from: .now) + 1)
	}

	/// The vintage year or edition number, or nil if it's out of range.
	var editionValue: Int16? {
		guard let number = Int16(editionNumber) else { return nil }
		return isVintage ? (Self.vintageYears.contains(number) ? number : nil) : (number > 0 ? number : nil)
	}

	var quantityValue: Int16 { Self.bottles(quantity) }
	var drankValue: Int16 { Self.bottles(drank) }

	/// The text fields left empty, by name.
	var missingDetails: [String] {
		[("name", name), ("domain", domain), ("creator", creator)]
			.filter { Validation.trimmed($0.1).isEmpty }
			.map(\.0)
	}

	var detailsError: String? {
		missingDetails.isEmpty ? nil : "Enter a \(ListFormatter.localizedString(byJoining: missingDetails))."
	}

	var editionError: String? {
		guard editionValue == nil else { return nil }
		return isVintage
			? "Enter a year between \(Self.vintageYears.lowerBound) and \(Self.vintageYears.upperBound)."
			: "Enter an edition number above 0."
	}

	/// The first check, top to bottom, that stops the wine being saved.
	var firstProblem: Problem? {
		if !missingDetails.isEmpty { return .details }
		if editionValue == nil { return .edition }
		return nil
	}

	/// Whether `wine` has these details, ignoring case and surrounding spaces in the text.
	func matches(_ wine: Item) -> Bool {
		guard let editionValue else { return false }
		return wine.matches(name: name, domain: domain, creator: creator, type: type,
							isVintage: isVintage, editionNumber: editionValue)
	}

	/// Writes everything except the photo to `wine`. Only call once `firstProblem` is nil.
	func apply(to wine: Item) {
		wine.setName(newName: Validation.trimmed(name))
		wine.setDomain(newDomain: Validation.trimmed(domain))
		wine.setCreator(newCreator: Validation.trimmed(creator))
		wine.setType(type)
		wine.setEdition(isVintage: isVintage, number: editionValue ?? 0)
		wine.setQuantity(newQuantity: quantityValue)
		wine.setDrank(newDrank: drankValue)
	}

	private static func bottles(_ text: String) -> Int16 {
		min(Int16(text) ?? 0, Item.maxBottles)
	}
}

/// A photo picked for a wine. Setting `item` loads it and shrinks it for storage; clearing it removes the photo.
@Observable
final class PickedPhoto {
	var item: PhotosPickerItem? {
		didSet { load() }
	}
	/// The photo ready to save, once it has loaded.
	private(set) var data: Data?
	private(set) var preview: Image?
	private(set) var isLoading = false

	private func load() {
		guard let item else {
			data = nil
			preview = nil
			return
		}
		isLoading = true
		Task {
			defer { isLoading = false }
			guard let original = try? await item.loadTransferable(type: Data.self),
				  let data = await Task.detached(operation: { compressedPhotoData(original) }).value,
				  let image = UIImage(data: data) else {
				return
			}
			self.data = data
			preview = Image(uiImage: image)
		}
	}
}

/// A labelled bottle count that can be typed or changed with a stepper.
struct BottleCountRow: View {
	let title: String
	@Binding var text: String
	let maximum: Int

	var body: some View {
		HStack {
			Text(title)
			Spacer()
			TextField("0", text: $text)
				.keyboardType(.numberPad)
				.multilineTextAlignment(.trailing)
				.monospacedDigit()
				.frame(width: 48)
				.digitsOnly($text, maxLength: 3)
			Stepper(title, value: Binding(
				get: { Int(text) ?? 0 },
				set: { text = String($0) }
			), in: 0...maximum)
			.labelsHidden()
		}
	}
}

/// A red validation message shown under a form section.
struct ErrorText: View {
	let message: String

	init(_ message: String) {
		self.message = message
	}

	var body: some View {
		Text(message)
			.foregroundStyle(.red)
	}
}

extension View {
	/// Keeps only ASCII digits in `text`, up to `maxLength` of them, including pasted text.
	func digitsOnly(_ text: Binding<String>, maxLength: Int) -> some View {
		onChange(of: text.wrappedValue) { _, newValue in
			let digits = String(newValue.filter { $0.isASCII && $0.isNumber }.prefix(maxLength))
			if digits != newValue {
				text.wrappedValue = digits
			}
		}
	}
}
