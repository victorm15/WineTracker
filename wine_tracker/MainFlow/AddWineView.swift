import SwiftUI
import PhotosUI
import Combine
import CoreData

struct AddWineView: View {
	@ObservedObject var currentPerson: Person
	@Environment(\.managedObjectContext) private var viewContext

	@State private var wineName = ""
	@State private var wineDomain = ""
	@State private var wineCreator = ""
	@State private var wineType = WineType.red
	@State private var wineQuantity = "1"
	@State private var wineDrank = "0"

	/// Vintage: `editionNumber` is a vintage year. Edition: it's an edition number.
	@State private var isVintage = true
	@State private var editionNumber = ""

	@State private var photoItem: PhotosPickerItem?
	/// The picked photo, already shrunk for storage.
	@State private var photoData: Data?
	@State private var photoPreview: Image?
	@State private var isLoadingPhoto = false

	/// Set after a failed Add, so missing or invalid fields show their messages.
	@State private var showErrors = false
	@State private var failedAttempts = 0
	/// Set when the entered wine is already in the collection; asks whether to add the bottles to it.
	@State private var duplicateWine: Item?
	@State private var saveFailed = false
	/// Shown briefly at the top after a wine is saved.
	@State private var savedMessage: String?
	@FocusState private var focusedField: Field?

	private enum Field: Hashable {
		case name, domain, creator, edition, quantity, drank
	}

	/// Bottle counts are capped at three digits, and so are the totals when adding to an existing wine.
	private let maxBottles: Int16 = 999

	private var vintageRange: ClosedRange<Int16> {
		1800...Int16(Calendar.current.component(.year, from: .now) + 1)
	}

	/// The vintage year or edition number, or nil if it's out of range.
	private var editionValue: Int16? {
		guard let number = Int16(editionNumber) else { return nil }
		if isVintage {
			return vintageRange.contains(number) ? number : nil
		}
		return number > 0 ? number : nil
	}

	private var isFormEmpty: Bool {
		[wineName, wineDomain, wineCreator, editionNumber].allSatisfy { trimmed($0).isEmpty }
			&& photoData == nil
	}

	var body: some View {
		ScrollViewReader { proxy in
			Form {
				Section {
					TextField("Name", text: $wineName)
						.focused($focusedField, equals: .name)
						.id(Field.name)
						.submitLabel(.next)
						.onSubmit { focusedField = .domain }
					TextField("Domain", text: $wineDomain)
						.focused($focusedField, equals: .domain)
						.id(Field.domain)
						.submitLabel(.next)
						.onSubmit { focusedField = .creator }
					TextField("Creator", text: $wineCreator)
						.focused($focusedField, equals: .creator)
						.id(Field.creator)
						.submitLabel(.next)
						.onSubmit { focusedField = .edition }
				} header: {
					Text("Wine")
				} footer: {
					if let message = detailsError {
						ErrorText(message)
					}
				}
				.textInputAutocapitalization(.words)
				.autocorrectionDisabled()

				Section("Type") {
					Picker("Type", selection: $wineType) {
						ForEach(WineType.allCases) { type in
							Text(type.shortName).tag(type)
						}
					}
					.pickerStyle(.segmented)
					.labelsHidden()
					.listRowBackground(Color.clear)
					.listRowInsets(EdgeInsets())
				}

				Section {
					Picker("Dated by", selection: $isVintage) {
						Text("Vintage").tag(true)
						Text("Edition").tag(false)
					}
					.pickerStyle(.segmented)
					.labelsHidden()
					TextField(isVintage ? "Vintage year, e.g. 2015" : "Edition number", text: $editionNumber)
						.keyboardType(.numberPad)
						.digitsOnly($editionNumber, maxLength: 4)
						.focused($focusedField, equals: .edition)
						.id(Field.edition)
				} header: {
					Text("Vintage or Edition")
				} footer: {
					if let message = editionError {
						ErrorText(message)
					}
				}

				Section("Bottles") {
					BottleCountRow(title: "Unopened", text: $wineQuantity, maximum: Int(maxBottles))
						.focused($focusedField, equals: .quantity)
					BottleCountRow(title: "Drank", text: $wineDrank, maximum: Int(maxBottles))
						.focused($focusedField, equals: .drank)
				}

				Section("Photo") {
					photoRow
				}

				Section {
					Button(action: addWine) {
						Text("Add Wine")
					}
					.buttonStyle(AuthPrimaryButtonStyle())
					.disabled(isLoadingPhoto)
					.listRowBackground(Color.clear)
					.listRowInsets(EdgeInsets())
				}
			}
			.onChange(of: failedAttempts) {
				guard let field = firstInvalidField else { return }
				withAnimation { proxy.scrollTo(field, anchor: .center) }
			}
		}
		.scrollDismissesKeyboard(.interactively)
		.navigationTitle("")
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Add Wine")
					.font(.custom("Cochin", size: 34))
					.foregroundColor(.accentColor)
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button("Clear", action: resetForm)
					.disabled(isFormEmpty)
			}
			ToolbarItemGroup(placement: .keyboard) {
				Spacer()
				Button("Done") { focusedField = nil }
			}
		}
		.overlay(alignment: .top) {
			if let savedMessage {
				Label(savedMessage, systemImage: "checkmark.circle.fill")
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(.white)
					.padding(.horizontal, 16)
					.padding(.vertical, 10)
					.background(Color.green.gradient, in: Capsule())
					.padding(.top, 8)
					.transition(.move(edge: .top).combined(with: .opacity))
			}
		}
		.task(id: savedMessage) {
			guard savedMessage != nil else { return }
			try? await Task.sleep(for: .seconds(2))
			withAnimation { savedMessage = nil }
		}
		.sensoryFeedback(.error, trigger: failedAttempts)
		.sensoryFeedback(.success, trigger: savedMessage) { _, new in new != nil }
		.alert("Already in Your Collection", isPresented: Binding(
			get: { duplicateWine != nil },
			set: { if !$0 { duplicateWine = nil } }
		), presenting: duplicateWine) { existing in
			Button("Add Bottles") { addBottles(to: existing) }
			Button("Cancel", role: .cancel) {}
		} message: { existing in
			Text("Add \(bottles(wineQuantity)) unopened and \(bottles(wineDrank)) drank to \(existing.wrappedName)?")
		}
		.alert("Couldn't Save Wine", isPresented: $saveFailed) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Something went wrong saving your collection. Please try again.")
		}
	}

	private var photoRow: some View {
		HStack(spacing: 14) {
			ZStack {
				RoundedRectangle(cornerRadius: 10)
					.fill(Color(.tertiarySystemFill))
				if isLoadingPhoto {
					ProgressView()
				} else if let photoPreview {
					photoPreview
						.resizable()
						.scaledToFill()
				} else {
					Image(systemName: "photo")
						.font(.title2)
						.foregroundStyle(.secondary)
				}
			}
			.frame(width: 64, height: 64)
			.clipShape(RoundedRectangle(cornerRadius: 10))

			PhotosPicker(selection: $photoItem, matching: .images) {
				Text(photoData == nil ? "Choose Photo" : "Change Photo")
			}
			.buttonStyle(.borderless)

			Spacer()

			if photoData != nil {
				Button("Remove", role: .destructive) {
					photoItem = nil
				}
				.buttonStyle(.borderless)
			}
		}
		.onChange(of: photoItem) {
			loadPhoto()
		}
	}

	private var detailsError: String? {
		guard showErrors else { return nil }
		let missing = [("name", wineName), ("domain", wineDomain), ("creator", wineCreator)]
			.filter { trimmed($0.1).isEmpty }
			.map(\.0)
		guard !missing.isEmpty else { return nil }
		return "Enter a \(ListFormatter.localizedString(byJoining: missing))."
	}

	private var editionError: String? {
		guard showErrors, editionValue == nil else { return nil }
		return isVintage
			? "Enter a year between \(vintageRange.lowerBound) and \(vintageRange.upperBound)."
			: "Enter an edition number above 0."
	}

	/// Checks the form, then either saves a new wine or asks to add the bottles to the matching one.
	private func addWine() {
		if let field = firstInvalidField {
			showErrors = true
			failedAttempts += 1
			// Focusing the field also scrolls it, and its message, into view.
			focusedField = field
			return
		}
		focusedField = nil
		if let existing = existingWine() {
			duplicateWine = existing
			return
		}

		let newItem = Item(context: viewContext)
		newItem.owner = currentPerson
		newItem.setName(newName: trimmed(wineName))
		newItem.setDomain(newDomain: trimmed(wineDomain))
		newItem.setCreator(newCreator: trimmed(wineCreator))
		newItem.setType(newType: wineType.rawValue)
		newItem.setQuantity(newQuantity: bottles(wineQuantity))
		newItem.setDrank(newDrank: bottles(wineDrank))
		if let photoData {
			newItem.setImageData(newImageData: photoData)
		}
		let newEdition = Edition(context: viewContext)
		newEdition.setIsEdition(newIsEdition: isVintage)
		newEdition.setNumber(newNumber: editionValue ?? 0)
		newEdition.wine = newItem

		if save() {
			showSaved("\(newItem.wrappedName) added")
		}
	}

	/// Adds the entered bottles to a wine already in the collection, keeping its photo unless a new one was picked.
	private func addBottles(to existing: Item) {
		existing.setQuantity(newQuantity: min(existing.wrappedQuantity + bottles(wineQuantity), maxBottles))
		existing.setDrank(newDrank: min(existing.wrappedDrank + bottles(wineDrank), maxBottles))
		if let photoData {
			existing.setImageData(newImageData: photoData)
		}
		if save() {
			// CollectionView observes the person, which doesn't change when one of its wines does.
			currentPerson.objectWillChange.send()
			showSaved("Bottles added to \(existing.wrappedName)")
		}
	}

	/// The first field, top to bottom, that stops the wine being saved.
	private var firstInvalidField: Field? {
		if trimmed(wineName).isEmpty { return .name }
		if trimmed(wineDomain).isEmpty { return .domain }
		if trimmed(wineCreator).isEmpty { return .creator }
		if editionValue == nil { return .edition }
		return nil
	}

	/// The wine in the collection with the same details, ignoring case and surrounding spaces.
	private func existingWine() -> Item? {
		currentPerson.itemsArray.first { item in
			sameText(item.wrappedName, wineName)
				&& sameText(item.wrappedDomain, wineDomain)
				&& sameText(item.wrappedCreator, wineCreator)
				&& item.wrappedType == wineType.rawValue
				&& item.wrappedEdition.wrappedIsEdition == isVintage
				&& item.wrappedEdition.wrappedNumber == editionValue
		}
	}

	/// Saves the context, or undoes the unsaved changes and shows an error.
	private func save() -> Bool {
		do {
			try viewContext.save()
			currentPerson.updateCache(viewContext: viewContext)
			return true
		} catch {
			viewContext.rollback()
			saveFailed = true
			return false
		}
	}

	private func showSaved(_ message: String) {
		resetForm()
		withAnimation { savedMessage = message }
	}

	private func loadPhoto() {
		guard let photoItem else {
			photoData = nil
			photoPreview = nil
			return
		}
		isLoadingPhoto = true
		Task {
			defer { isLoadingPhoto = false }
			guard let original = try? await photoItem.loadTransferable(type: Data.self),
				  let data = await Task.detached(operation: { compressedPhotoData(original) }).value,
				  let image = UIImage(data: data) else {
				return
			}
			photoData = data
			photoPreview = Image(uiImage: image)
		}
	}

	private func resetForm() {
		wineName = ""
		wineDomain = ""
		wineCreator = ""
		wineType = .red
		wineQuantity = "1"
		wineDrank = "0"
		isVintage = true
		editionNumber = ""
		photoItem = nil
		photoData = nil
		photoPreview = nil
		showErrors = false
		focusedField = nil
	}

	private func trimmed(_ text: String) -> String {
		text.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private func sameText(_ stored: String, _ entered: String) -> Bool {
		trimmed(stored).caseInsensitiveCompare(trimmed(entered)) == .orderedSame
	}

	private func bottles(_ text: String) -> Int16 {
		min(Int16(text) ?? 0, maxBottles)
	}
}

private extension WineType {
	/// Fits a segmented control.
	var shortName: String {
		switch self {
		case .red: "Red"
		case .white: "White"
		case .champagne: "Champagne"
		}
	}
}

/// A labelled bottle count that can be typed or changed with a stepper.
private struct BottleCountRow: View {
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
private struct ErrorText: View {
	let message: String

	init(_ message: String) {
		self.message = message
	}

	var body: some View {
		Text(message)
			.foregroundStyle(.red)
	}
}

private extension View {
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

#Preview {
	NavigationStack {
		AddWineView(currentPerson: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
