import SwiftUI
import CoreData
import PhotosUI

/// Edits a wine in place. If the edits make it the same as another wine in the collection,
/// offers to combine the two.
struct EditWineView: View {
	@ObservedObject var wine: Item
	let owner: Person
	@Environment(\.managedObjectContext) private var viewContext
	@Environment(\.dismiss) private var dismiss

	@State private var name = ""
	@State private var domain = ""
	@State private var creator = ""
	@State private var type = WineType.red
	@State private var isVintage = true
	@State private var editionNumber = ""
	@State private var quantity = ""
	@State private var drank = ""

	@State private var photoItem: PhotosPickerItem?
	@State private var newPhotoData: Data?
	@State private var newPhotoPreview: Image?
	@State private var isLoadingPhoto = false

	@State private var hasLoaded = false
	@State private var showErrors = false
	@State private var matchingWine: Item?
	@State private var saveFailed = false

	private var vintageRange: ClosedRange<Int16> {
		1800...Int16(Calendar.current.component(.year, from: .now) + 1)
	}

	private var editionValue: Int16? {
		guard let number = Int16(editionNumber) else { return nil }
		return isVintage ? (vintageRange.contains(number) ? number : nil) : (number > 0 ? number : nil)
	}

	private var detailsError: String? {
		let missing = [("name", name), ("domain", domain), ("creator", creator)]
			.filter { trimmed($0.1).isEmpty }
			.map(\.0)
		return missing.isEmpty ? nil : "Enter a \(ListFormatter.localizedString(byJoining: missing))."
	}

	private var editionError: String? {
		guard editionValue == nil else { return nil }
		return isVintage
			? "Enter a year between \(vintageRange.lowerBound) and \(vintageRange.upperBound)."
			: "Enter an edition number above 0."
	}

	var body: some View {
		Form {
			Section {
				TextField("Name", text: $name)
				TextField("Domain", text: $domain)
				TextField("Creator", text: $creator)
			} header: {
				Text("Wine")
			} footer: {
				if showErrors, let detailsError { ErrorText(detailsError) }
			}
			.textInputAutocapitalization(.words)
			.autocorrectionDisabled()

			Section("Type") {
				Picker("Type", selection: $type) {
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
				TextField(isVintage ? "Vintage year" : "Edition number", text: $editionNumber)
					.keyboardType(.numberPad)
					.digitsOnly($editionNumber, maxLength: 4)
			} header: {
				Text("Vintage or Edition")
			} footer: {
				if showErrors, let editionError { ErrorText(editionError) }
			}

			Section("Bottles") {
				BottleCountRow(title: "Unopened", text: $quantity, maximum: Int(Item.maxBottles))
				BottleCountRow(title: "Drank", text: $drank, maximum: Int(Item.maxBottles))
			}

			Section("Photo") {
				HStack(spacing: 14) {
					Group {
						if isLoadingPhoto {
							ProgressView()
						} else if let newPhotoPreview {
							newPhotoPreview.resizable().scaledToFill()
						} else {
							wine.wrappedImage.resizable().scaledToFill()
						}
					}
					.frame(width: 64, height: 64)
					.background(Color(.tertiarySystemFill))
					.clipShape(RoundedRectangle(cornerRadius: 10))

					PhotosPicker("Change Photo", selection: $photoItem, matching: .images)
						.buttonStyle(.borderless)
				}
				.onChange(of: photoItem) { loadPhoto() }
			}
		}
		.navigationTitle("Edit Wine")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") { dismiss() }
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Save", action: save)
					.disabled(isLoadingPhoto)
			}
		}
		.onAppear(perform: load)
		.alert(
			"Already in Your Collection",
			isPresented: Binding(get: { matchingWine != nil }, set: { if !$0 { matchingWine = nil } }),
			presenting: matchingWine
		) { other in
			Button("Combine") { combine(into: other) }
			Button("Cancel", role: .cancel) {}
		} message: { other in
			Text("You already have \(other.wrappedName) \(other.editionLabel). Combine this wine's bottles into it?")
		}
		.alert("Couldn't Save Wine", isPresented: $saveFailed) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Something went wrong. Nothing was changed.")
		}
	}

	private func load() {
		guard !hasLoaded else { return }
		hasLoaded = true
		name = wine.wrappedName
		domain = wine.wrappedDomain
		creator = wine.wrappedCreator
		type = WineType(rawValue: wine.wrappedType) ?? .red
		isVintage = wine.isVintage
		editionNumber = String(wine.editionNumber)
		quantity = String(wine.wrappedQuantity)
		drank = String(wine.wrappedDrank)
	}

	private func save() {
		guard detailsError == nil, let editionValue else {
			showErrors = true
			return
		}
		let match = owner.itemsArray.first {
			$0 != wine && $0.matches(name: name, domain: domain, creator: creator,
									  type: type.rawValue, isVintage: isVintage, editionNumber: editionValue)
		}
		if let match {
			matchingWine = match
			return
		}

		wine.setName(newName: trimmed(name))
		wine.setDomain(newDomain: trimmed(domain))
		wine.setCreator(newCreator: trimmed(creator))
		wine.setType(newType: type.rawValue)
		wine.setQuantity(newQuantity: bottles(quantity))
		wine.setDrank(newDrank: bottles(drank))
		if let newPhotoData {
			wine.setImageData(newImageData: newPhotoData)
		}
		let edition = wine.edition ?? Edition(context: viewContext)
		edition.setIsEdition(newIsEdition: isVintage)
		edition.setNumber(newNumber: editionValue)
		edition.wine = wine
		finishSaving()
	}

	/// Adds this wine's bottles (and photo, if the other has none) to `other`, then deletes this wine.
	private func combine(into other: Item) {
		other.setQuantity(newQuantity: min(other.wrappedQuantity + bottles(quantity), Item.maxBottles))
		other.setDrank(newDrank: min(other.wrappedDrank + bottles(drank), Item.maxBottles))
		if let photo = newPhotoData ?? wine.storedImageData, other.storedImageData == nil || newPhotoData != nil {
			other.setImageData(newImageData: photo)
		}
		viewContext.delete(wine)
		finishSaving()
	}

	private func finishSaving() {
		if viewContext.saveOrRollback() {
			dismiss()
		} else {
			saveFailed = true
		}
	}

	private func loadPhoto() {
		guard let photoItem else { return }
		isLoadingPhoto = true
		Task {
			defer { isLoadingPhoto = false }
			guard let original = try? await photoItem.loadTransferable(type: Data.self),
				  let data = await Task.detached(operation: { compressedPhotoData(original) }).value,
				  let image = UIImage(data: data) else {
				return
			}
			newPhotoData = data
			newPhotoPreview = Image(uiImage: image)
		}
	}

	private func trimmed(_ text: String) -> String {
		text.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private func bottles(_ text: String) -> Int16 {
		min(Int16(text) ?? 0, Item.maxBottles)
	}
}

#Preview {
	NavigationStack {
		EditWineView(wine: PersistenceController.previewPerson.itemsArray[0], owner: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
