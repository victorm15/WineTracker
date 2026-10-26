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

	@State private var draft = WineDraft()
	/// The wine's details when the page opened, to tell whether anything has changed.
	@State private var original = WineDraft()
	@State private var photo = PickedPhoto()

	@State private var hasLoaded = false
	@State private var showErrors = false
	@State private var matchingWine: Item?
	@State private var saveFailed = false

	private var hasChanges: Bool {
		draft != original || photo.data != nil
	}

	var body: some View {
		Form {
			Section {
				TextField("Name", text: $draft.name)
				TextField("Domain", text: $draft.domain)
				TextField("Creator", text: $draft.creator)
			} header: {
				Text("Wine")
			} footer: {
				if showErrors, let error = draft.detailsError { ErrorText(error) }
			}
			.textInputAutocapitalization(.words)
			.autocorrectionDisabled()

			Section("Type") {
				Picker("Type", selection: $draft.type) {
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
				Picker("Dated by", selection: $draft.isVintage) {
					Text("Vintage").tag(true)
					Text("Edition").tag(false)
				}
				.pickerStyle(.segmented)
				.labelsHidden()
				TextField(draft.isVintage ? "Vintage year" : "Edition number", text: $draft.editionNumber)
					.keyboardType(.numberPad)
					.digitsOnly($draft.editionNumber, maxLength: 4)
			} header: {
				Text("Vintage or Edition")
			} footer: {
				if showErrors, let error = draft.editionError { ErrorText(error) }
			}

			Section("Bottles") {
				BottleCountRow(title: "Unopened", text: $draft.quantity, maximum: Int(Item.maxBottles))
				BottleCountRow(title: "Drank", text: $draft.drank, maximum: Int(Item.maxBottles))
			}

			Section("Photo") {
				HStack(spacing: 14) {
					Group {
						if photo.isLoading {
							ProgressView()
						} else if let preview = photo.preview {
							preview.resizable().scaledToFill()
						} else {
							wine.wrappedImage.resizable().scaledToFill()
						}
					}
					.frame(width: 64, height: 64)
					.background(Color(.tertiarySystemFill))
					.clipShape(RoundedRectangle(cornerRadius: 10))

					PhotosPicker("Change Photo", selection: $photo.item, matching: .images)
						.buttonStyle(.borderless)
				}
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
					.disabled(!hasChanges || photo.isLoading)
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
		draft = WineDraft(wine)
		original = draft
	}

	private func save() {
		guard draft.firstProblem == nil else {
			showErrors = true
			return
		}
		if let match = owner.wines.first(where: { $0 != wine && draft.matches($0) }) {
			matchingWine = match
			return
		}
		draft.apply(to: wine)
		if let data = photo.data {
			wine.setImageData(newImageData: data)
		}
		finishSaving()
	}

	/// Adds this wine's bottles (and photo, if the other has none) to `other`, then deletes this wine.
	private func combine(into other: Item) {
		other.setQuantity(newQuantity: min(other.wrappedQuantity + draft.quantityValue, Item.maxBottles))
		other.setDrank(newDrank: min(other.wrappedDrank + draft.drankValue, Item.maxBottles))
		if let newPhoto = photo.data ?? wine.storedImageData, other.storedImageData == nil || photo.data != nil {
			other.setImageData(newImageData: newPhoto)
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
}

#Preview {
	NavigationStack {
		EditWineView(wine: PersistenceController.previewPerson.wines(matching: WineQuery())[0], owner: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
