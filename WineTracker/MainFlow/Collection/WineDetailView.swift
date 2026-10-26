import SwiftUI
import CoreData

/// One wine's photo and details, with quick bottle counting, editing and deleting.
struct WineDetailView: View {
	@ObservedObject var wine: Item
	let owner: Person
	@Environment(\.managedObjectContext) private var viewContext
	@Environment(\.dismiss) private var dismiss

	@State private var isEditing = false
	@State private var confirmingDelete = false

	var body: some View {
		// The wine can be deleted from the edit sheet (when combined) while this page is still shown.
		if wine.isDeleted || wine.managedObjectContext == nil {
			Color.clear.onAppear { dismiss() }
		} else {
			content
		}
	}

	private var content: some View {
		List {
			Section {
				VStack(spacing: 12) {
					wine.wrappedImage
						.resizable()
						.scaledToFill()
						.frame(maxWidth: .infinity)
						.frame(height: 240)
						.clipShape(RoundedRectangle(cornerRadius: 16))
					VStack(spacing: 4) {
						Text(wine.wrappedName)
							.font(.custom("Cochin-Bold", size: 28))
							.multilineTextAlignment(.center)
						Text("\(wine.wrappedCreator) · \(wine.wrappedDomain)")
							.foregroundStyle(.secondary)
							.multilineTextAlignment(.center)
						HStack(spacing: 6) {
							WineTypeBadge(type: wine.wrappedType)
							Text(wine.editionLabel)
								.font(.subheadline)
								.foregroundStyle(.secondary)
						}
					}
				}
				.frame(maxWidth: .infinity)
				.listRowBackground(Color.clear)
				.listRowInsets(EdgeInsets())
			}

			Section("Bottles") {
				LabeledContent("Unopened") {
					Text(wine.wrappedQuantity, format: .number)
						.contentTransition(.numericText())
				}
				LabeledContent("Drank") {
					Text(wine.wrappedDrank, format: .number)
						.contentTransition(.numericText())
				}
				Button {
					drinkBottle()
				} label: {
					Label("Drank a Bottle", systemImage: "wineglass")
				}
				.disabled(wine.wrappedQuantity == 0)
				Button {
					addBottle()
				} label: {
					Label("Bought a Bottle", systemImage: "plus.circle")
				}
				.disabled(wine.wrappedQuantity >= Item.maxBottles)
			}

			Section {
				Button("Delete Wine", role: .destructive) {
					confirmingDelete = true
				}
			}
		}
		.navigationTitle("")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Edit") { isEditing = true }
			}
		}
		.sheet(isPresented: $isEditing) {
			NavigationStack {
				EditWineView(wine: wine, owner: owner)
			}
		}
		.confirmationDialog("Delete \(wine.wrappedName)?", isPresented: $confirmingDelete, titleVisibility: .visible) {
			Button("Delete Wine", role: .destructive, action: delete)
		} message: {
			Text("This removes the wine and its bottle counts from your collection.")
		}
		.sensoryFeedback(.increase, trigger: wine.wrappedDrank)
	}

	private func drinkBottle() {
		guard wine.wrappedQuantity > 0 else { return }
		withAnimation {
			wine.setQuantity(newQuantity: wine.wrappedQuantity - 1)
			wine.setDrank(newDrank: min(wine.wrappedDrank + 1, Item.maxBottles))
		}
		_ = viewContext.saveOrRollback()
	}

	private func addBottle() {
		withAnimation {
			wine.setQuantity(newQuantity: min(wine.wrappedQuantity + 1, Item.maxBottles))
		}
		_ = viewContext.saveOrRollback()
	}

	private func delete() {
		dismiss()
		viewContext.delete(wine)
		_ = viewContext.saveOrRollback()
	}
}

#Preview {
	NavigationStack {
		WineDetailView(wine: PersistenceController.previewPerson.itemsArray[0], owner: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
