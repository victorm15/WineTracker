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
	@State private var wineQuantity = ""
	@State private var wineDrank = ""

	/// On: `editionNumber` is a vintage year. Off: it's an edition number.
	@State private var isVintage = true
	@State private var editionNumber = ""

	@State private var photoItem: PhotosPickerItem?
	/// The picked photo, already shrunk for storage.
	@State private var photoData: Data?
	@State private var photoPreview: Image?

	/// Set when the entered wine is already in the collection; asks whether to add the bottles to it.
	@State private var duplicateWine: Item?
	/// Why the form can't be saved, shown in a popover.
	@State private var formProblem: String?
	@State private var saveFailed = false

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

	var body: some View {
		ZStack{
			LinearGradient(colors: [ Color(UIColor(rgb: 0xf2f2f7)), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
				.ignoresSafeArea()
			VStack{
				WineTextField(title: "Wine Name", text: $wineName)
				WineTextField(title: "Wine Domain", text: $wineDomain)
				WineTextField(title: "Wine Creator", text: $wineCreator)

				HStack {
					DigitsField(title: "Unopened Bottles", text: $wineQuantity, maxLength: 3)
					DigitsField(title: "Bottles Drank", text: $wineDrank, maxLength: 3)
				}

				Text("Type")
					.font(.custom("Cochin", size:20))
					.foregroundStyle(.gray)
				Menu {
					ForEach(WineType.allCases) { type in
						Button {
							wineType = type
						} label: {
							Text(type.rawValue)
								.font(.custom("Cochin", size:20))
						}
					}
				} label: {
					ZStack{
						Rectangle()
							.fill(.white)
							.frame(height:30)
						Text("^ \(wineType.rawValue) ^")
							.foregroundColor(Color.lighterGray)
							.font(.custom("Cochin", size:20))
					}
				}

				HStack{
					VStack{
						Text("Vintage")
							.font(.custom("Cochin", size:20))
							.foregroundColor(Color.accentColor)
						Toggle(isOn: $isVintage) {}
							.offset(x:-25)
					}
					DigitsField(title: isVintage ? "Vintage Year" : "Edition Number", text: $editionNumber, maxLength: 4)
						.frame(width: 280)
						.offset(y:15)
				}
				VStack {
					Text("Image")
						.font(.custom("Cochin", size:20))
						.foregroundColor(Color.accentColor)

					PhotosPicker(selection: $photoItem, matching: .images) {
						if let photoPreview {
							photoPreview
								.resizable()
								.scaledToFill()
								.frame(width:100,height:100)
								.clipped()
						}
						else{
							Image(systemName:"plus.square.dashed")
								.resizable()
								.frame(width:100,height:100)
								.foregroundColor(Color.accentColor)
						}
					}
					.onChange(of: photoItem) {
						loadPhoto()
					}
				}

				Button("Add Wine", action: addWine)
					.popover(item: $duplicateWine) { existing in
						ZStack {
							RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

							VStack{
								Text("Wine Already Exists")
								Text("Add To Recorded Bottles?")
								HStack{
									Button("No") {
										duplicateWine = nil
									}
									.buttonStyle(AccountButton())
									Button("Yes") {
										duplicateWine = nil
										addBottles(to: existing)
									}
								}
							}
						}
					}
					.popover(isPresented: Binding(
						get: { formProblem != nil },
						set: { if !$0 { formProblem = nil } }
					)) {
						ZStack {
							RadialGradient(gradient: Gradient(colors: [Color.lighterGray, .white,Color.lighterGray,.white]), center: .center, startRadius: 140, endRadius: 300)

							VStack{
								Text("Can't Add This Wine")
								Text(formProblem ?? "")
								HStack{
									Button("Ok") {
										formProblem = nil
									}
									.buttonStyle(AccountButton())
								}
							}
						}
					}
					.buttonStyle(AccountButton())
					.font(.custom("Cochin", size:20))
				Button("Clear", action: resetForm)
					.offset(x:90,y:-45)
			}
			.navigationTitle("")
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Add Wine")
						.font(.custom("Cochin", size: 34))
						.foregroundColor(.accentColor)
				}
			}
		}
		.alert("Couldn't Save Wine", isPresented: $saveFailed) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Something went wrong saving your collection. Please try again.")
		}
	}

	/// Checks the form, then either saves a new wine or asks to add the bottles to the matching one.
	private func addWine() {
		if let problem = problemWithForm() {
			formProblem = problem
			return
		}
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
			resetForm()
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
			resetForm()
		}
	}

	private func problemWithForm() -> String? {
		let required = [wineName, wineDomain, wineCreator, wineQuantity, wineDrank, editionNumber]
		if required.contains(where: { trimmed($0).isEmpty }) {
			return "Please provide entries to each text field"
		}
		if editionValue == nil {
			return isVintage
				? "Vintage year must be between \(vintageRange.lowerBound) and \(vintageRange.upperBound)"
				: "Edition number must be above 0"
		}
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

	private func loadPhoto() {
		guard let photoItem else {
			photoData = nil
			photoPreview = nil
			return
		}
		Task {
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
		wineQuantity = ""
		wineDrank = ""
		isVintage = true
		editionNumber = ""
		photoItem = nil
		photoData = nil
		photoPreview = nil
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

/// The rounded text field used throughout the add wine form.
private struct WineTextField: View {
	let title: String
	@Binding var text: String

	var body: some View {
		TextField(title, text: $text)
			.textFieldStyle(.roundedBorder)
			.textInputAutocapitalization(.never)
			.autocorrectionDisabled()
			.font(.custom("Cochin", size:20))
	}
}

/// A number pad field that only keeps up to `maxLength` digits, including pasted text.
private struct DigitsField: View {
	let title: String
	@Binding var text: String
	let maxLength: Int

	var body: some View {
		WineTextField(title: title, text: $text)
			.keyboardType(.numberPad)
			.onChange(of: text) { _, newValue in
				let digits = String(newValue.filter { $0.isASCII && $0.isNumber }.prefix(maxLength))
				if digits != newValue {
					text = digits
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
