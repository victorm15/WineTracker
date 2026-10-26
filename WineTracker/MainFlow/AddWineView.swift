import SwiftUI
import PhotosUI
import CoreData

struct AddWineView: View {
	@ObservedObject var currentPerson: Person
	@Environment(\.managedObjectContext) private var viewContext

	@State private var draft = WineDraft()
	@State private var photo = PickedPhoto()

	/// Set after a failed Add, so missing or invalid fields show their messages.
	@State private var showErrors = false
	@State private var failedAttempts = 0
	/// Set when the entered wine is already in the collection; asks whether to add the bottles to it.
	@State private var duplicateWine: Item?
	@State private var saveFailed = false
	/// Shown briefly at the top after a wine is saved.
	@State private var savedMessage: String?
	@FocusState private var focusedField: Field?

	/// Raw values match `WineDraft.missingDetails`.
	private enum Field: String, Hashable {
		case name, domain, creator, edition, quantity, drank
	}

	private var isFormEmpty: Bool {
		[draft.name, draft.domain, draft.creator, draft.editionNumber].allSatisfy { Validation.trimmed($0).isEmpty }
			&& photo.data == nil
	}

	var body: some View {
		ScrollViewReader { proxy in
			Form {
				Section {
					TextField("Name", text: $draft.name)
						.focused($focusedField, equals: .name)
						.id(Field.name)
						.submitLabel(.next)
						.onSubmit { focusedField = .domain }
					TextField("Domain", text: $draft.domain)
						.focused($focusedField, equals: .domain)
						.id(Field.domain)
						.submitLabel(.next)
						.onSubmit { focusedField = .creator }
					TextField("Creator", text: $draft.creator)
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
					TextField(draft.isVintage ? "Vintage year, e.g. 2015" : "Edition number", text: $draft.editionNumber)
						.keyboardType(.numberPad)
						.digitsOnly($draft.editionNumber, maxLength: 4)
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
					BottleCountRow(title: "Unopened", text: $draft.quantity, maximum: Int(Item.maxBottles))
						.focused($focusedField, equals: .quantity)
					BottleCountRow(title: "Drank", text: $draft.drank, maximum: Int(Item.maxBottles))
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
					.disabled(photo.isLoading)
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
			Text("Add \(draft.quantityValue) unopened and \(draft.drankValue) drank to \(existing.wrappedName)?")
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
				if photo.isLoading {
					ProgressView()
				} else if let preview = photo.preview {
					preview
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

			PhotosPicker(selection: $photo.item, matching: .images) {
				Text(photo.data == nil ? "Choose Photo" : "Change Photo")
			}
			.buttonStyle(.borderless)

			Spacer()

			if photo.data != nil {
				Button("Remove", role: .destructive) {
					photo.item = nil
				}
				.buttonStyle(.borderless)
			}
		}
	}

	private var detailsError: String? {
		showErrors ? draft.detailsError : nil
	}

	private var editionError: String? {
		showErrors ? draft.editionError : nil
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
		if let existing = currentPerson.wines.first(where: draft.matches) {
			duplicateWine = existing
			return
		}

		let newItem = Item(context: viewContext)
		newItem.owner = currentPerson
		draft.apply(to: newItem)
		if let data = photo.data {
			newItem.setImageData(newImageData: data)
		}
		if save() {
			showSaved("\(newItem.wrappedName) added")
		}
	}

	/// Adds the entered bottles to a wine already in the collection, keeping its photo unless a new one was picked.
	private func addBottles(to existing: Item) {
		existing.setQuantity(newQuantity: min(existing.wrappedQuantity + draft.quantityValue, Item.maxBottles))
		existing.setDrank(newDrank: min(existing.wrappedDrank + draft.drankValue, Item.maxBottles))
		if let data = photo.data {
			existing.setImageData(newImageData: data)
		}
		if save() {
			showSaved("Bottles added to \(existing.wrappedName)")
		}
	}

	/// The first field, top to bottom, that stops the wine being saved.
	private var firstInvalidField: Field? {
		switch draft.firstProblem {
		case .details: draft.missingDetails.first.flatMap(Field.init(rawValue:))
		case .edition: .edition
		case nil: nil
		}
	}

	/// Saves, or undoes the unsaved changes and shows an error.
	private func save() -> Bool {
		guard viewContext.saveOrRollback() else {
			saveFailed = true
			return false
		}
		return true
	}

	private func showSaved(_ message: String) {
		resetForm()
		withAnimation { savedMessage = message }
	}

	private func resetForm() {
		draft = WineDraft()
		photo.item = nil
		showErrors = false
		focusedField = nil
	}
}

#Preview {
	NavigationStack {
		AddWineView(currentPerson: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
