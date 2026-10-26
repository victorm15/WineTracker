import SwiftUI
import CoreData

/// The account's wines, searchable by name, domain or creator, filterable by type and sortable.
struct CollectionView: View {
	@ObservedObject var currentPerson: Person
	@Environment(\.managedObjectContext) private var viewContext

	@State private var searchText = ""
	@State private var searchField = SearchField.name
	@State private var typeFilter: WineType?
	@State private var sortField = SortField.name
	@State private var sortAscending = true
	@State private var wines: [Item] = []
	@State private var wineToDelete: Item?
	/// Bumped on every save so the header totals redraw even when the list of wines is unchanged.
	@State private var revision = 0

	enum SearchField: String, CaseIterable, Identifiable {
		case name = "Name", domain = "Domain", creator = "Creator"
		var id: Self { self }
	}

	enum SortField: String, CaseIterable, Identifiable {
		case name = "Name", domain = "Domain", creator = "Creator"
		var id: Self { self }
	}

	/// The `getWines` query for the current settings; also the key its results are cached under.
	private var query: (filter: String, search: String, sort: String, type: String) {
		(searchField.rawValue, searchText.trimmingCharacters(in: .whitespaces),
		 sortField.rawValue + (sortAscending ? "A" : "D"), typeFilter?.rawValue ?? "Any")
	}

	private var isFiltering: Bool {
		!query.search.isEmpty || typeFilter != nil
	}

	var body: some View {
		List {
			if !wines.isEmpty {
				Section {
					ForEach(wines) { wine in
						NavigationLink {
							WineDetailView(wine: wine, owner: currentPerson)
						} label: {
							WineRow(wine: wine)
						}
						.swipeActions(edge: .leading) {
							Button {
								drinkBottle(of: wine)
							} label: {
								Label("Drank One", systemImage: "wineglass")
							}
							.tint(.accentColor)
							.disabled(wine.wrappedQuantity == 0)
						}
						.swipeActions(edge: .trailing) {
							Button(role: .destructive) {
								wineToDelete = wine
							} label: {
								Label("Delete", systemImage: "trash")
							}
						}
					}
				} header: {
					Text(summary)
						.id(revision)
				}
			}
		}
		.listStyle(.insetGrouped)
		.overlay {
			if wines.isEmpty {
				emptyState
			}
		}
		.searchable(text: $searchText, prompt: "Search by \(searchField.rawValue.lowercased())")
		.searchScopes($searchField) {
			ForEach(SearchField.allCases) { field in
				Text(field.rawValue).tag(field)
			}
		}
		.textInputAutocapitalization(.never)
		.autocorrectionDisabled()
		.navigationTitle("")
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Collection")
					.font(.custom("Cochin", size: 34))
					.foregroundColor(.accentColor)
			}
			ToolbarItem(placement: .topBarTrailing) {
				filterMenu
			}
		}
		.onAppear(perform: reloadWines)
		.onChange(of: query.filter) { reloadWines() }
		.onChange(of: query.search) { reloadWines() }
		.onChange(of: query.sort) { reloadWines() }
		.onChange(of: query.type) { reloadWines() }
		// Edits made elsewhere (detail page, Add Wine, merges) change what the list should show.
		.onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: viewContext)) { _ in
			currentPerson.updateCache(viewContext: viewContext)
			reloadWines()
			revision += 1
		}
		.confirmationDialog(
			"Delete \(wineToDelete?.wrappedName ?? "wine")?",
			isPresented: Binding(get: { wineToDelete != nil }, set: { if !$0 { wineToDelete = nil } }),
			titleVisibility: .visible,
			presenting: wineToDelete
		) { wine in
			Button("Delete Wine", role: .destructive) {
				viewContext.delete(wine)
				_ = viewContext.saveOrRollback()
			}
		} message: { _ in
			Text("This removes the wine and its bottle counts from your collection.")
		}
	}

	private var filterMenu: some View {
		Menu {
			Picker("Type", selection: $typeFilter) {
				Text("All Types").tag(WineType?.none)
				ForEach(WineType.allCases) { type in
					Text(type.rawValue).tag(Optional(type))
				}
			}
			Section("Sort By") {
				Picker("Sort By", selection: $sortField) {
					ForEach(SortField.allCases) { field in
						Text(field.rawValue).tag(field)
					}
				}
				Picker("Order", selection: $sortAscending) {
					Label("A to Z", systemImage: "arrow.up").tag(true)
					Label("Z to A", systemImage: "arrow.down").tag(false)
				}
			}
		} label: {
			Label("Filter and Sort", systemImage: typeFilter == nil
				? "line.3.horizontal.decrease.circle"
				: "line.3.horizontal.decrease.circle.fill")
		}
	}

	private var summary: String {
		let bottles = wines.reduce(0) { $0 + Int($1.wrappedQuantity) }
		let wineText = "\(wines.count) \(wines.count == 1 ? "wine" : "wines")"
		let bottleText = "\(bottles) unopened \(bottles == 1 ? "bottle" : "bottles")"
		let typeText = typeFilter.map { " · \($0.rawValue)" } ?? ""
		return "\(wineText) · \(bottleText)\(typeText)"
	}

	@ViewBuilder
	private var emptyState: some View {
		if !query.search.isEmpty {
			ContentUnavailableView.search(text: query.search)
		} else if let typeFilter {
			ContentUnavailableView {
				Label("No \(typeFilter.rawValue)", systemImage: "wineglass")
			} description: {
				Text("Nothing in your collection matches this type.")
			} actions: {
				Button("Show All Types") { self.typeFilter = nil }
			}
		} else {
			ContentUnavailableView(
				"No Wines Yet",
				systemImage: "wineglass",
				description: Text("Wines you add appear here.")
			)
		}
	}

	private func drinkBottle(of wine: Item) {
		guard wine.wrappedQuantity > 0 else { return }
		wine.setQuantity(newQuantity: wine.wrappedQuantity - 1)
		wine.setDrank(newDrank: min(wine.wrappedDrank + 1, Item.maxBottles))
		_ = viewContext.saveOrRollback()
	}

	private func reloadWines() {
		wines = currentPerson.getWines(
			FilterType: query.filter,
			FilterString: query.search,
			SortType: query.sort,
			WineType: query.type,
			viewContext: viewContext
		)
	}
}

/// One wine in the collection list: photo, name, maker and bottle count.
private struct WineRow: View {
	@ObservedObject var wine: Item

	var body: some View {
		HStack(spacing: 14) {
			WineThumbnail(wine: wine, size: 56)

			VStack(alignment: .leading, spacing: 3) {
				Text(wine.wrappedName)
					.font(.custom("Cochin-Bold", size: 19))
					.lineLimit(1)
				Text("\(wine.wrappedCreator) · \(wine.wrappedDomain)")
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.lineLimit(1)
				HStack(spacing: 6) {
					WineTypeBadge(type: wine.wrappedType)
					Text(wine.editionLabel)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}

			Spacer(minLength: 8)

			VStack(spacing: 0) {
				Text(wine.wrappedQuantity, format: .number)
					.font(.system(.title3, design: .rounded, weight: .semibold))
					.foregroundStyle(wine.wrappedQuantity == 0 ? Color.secondary : Color.accentColor)
					.contentTransition(.numericText())
				Text("left")
					.font(.caption2)
					.foregroundStyle(.secondary)
			}
			.frame(minWidth: 36)
		}
		.padding(.vertical, 4)
		.accessibilityElement(children: .combine)
	}
}

#Preview {
	NavigationStack {
		CollectionView(currentPerson: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
