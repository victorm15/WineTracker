import SwiftUI

/// The account's bottle totals and a few highlights picked from the collection.
struct HomeView: View {
	@ObservedObject var currentPerson: Person
	/// Opens the Add Wine tab from the empty-collection message.
	var onAddWine: () -> Void = {}
	@Environment(QueryCache.self) private var queryCache

	var body: some View {
		// Reading the revision redraws Home after every save, including bottle count changes.
		let _ = queryCache.revision
		// The whole collection sorted by name: the same list Collection shows by default.
		let summary = CollectionSummary(queryCache.peek(WineQuery()))
		ScrollView {
			VStack(alignment: .leading, spacing: 28) {
				greeting
				statistics(summary)
				if summary.isEmpty {
					emptyCollection
				} else {
					highlights(summary)
				}
			}
			.padding()
		}
		.background(Color(.systemGroupedBackground))
		.navigationTitle("")
	}

	private var greeting: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text("Hello, \(currentPerson.wrappedFirstName)")
				.font(.custom("Cochin-Bold", size: 30))
			Text("@\(currentPerson.wrappedUsername)")
				.font(.subheadline)
				.foregroundStyle(.secondary)
		}
	}

	private func statistics(_ summary: CollectionSummary) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			SectionTitle("Bottles")
			HStack(spacing: 12) {
				StatTile(value: summary.unopened, label: "Unopened")
				StatTile(value: summary.drank, label: "Drank")
				StatTile(value: summary.unopened + summary.drank, label: "Recorded")
			}
		}
	}

	private func highlights(_ summary: CollectionSummary) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			SectionTitle("Highlights")
			if let wine = summary.mostOwned {
				WineHighlightCard(title: "Most owned", systemImage: "trophy.fill", wine: wine)
			}
			if let wine = summary.favorite {
				WineHighlightCard(title: "Favorite", systemImage: "heart.fill", wine: wine)
			}
			if let wine = summary.needToBuy {
				WineHighlightCard(title: "You may need to buy some", systemImage: "cart.fill", wine: wine)
			}
			if let wine = summary.tryNew {
				WineHighlightCard(title: "Try something new?", systemImage: "sparkles", wine: wine)
			}
		}
	}

	private var emptyCollection: some View {
		VStack(spacing: 14) {
			Image(systemName: "wineglass")
				.font(.system(size: 36))
				.foregroundStyle(Color.accentColor)
			Text("Your collection is empty")
				.font(.custom("Cochin-Bold", size: 22))
			Text("Add a wine to see your highlights here.")
				.font(.subheadline)
				.foregroundStyle(.secondary)
			Button("Add a Wine", action: onAddWine)
				.buttonStyle(AccountButton())
				.font(.custom("Cochin", size: 20))
		}
		.frame(maxWidth: .infinity)
		.padding(24)
		.background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
	}
}

/// Bottle totals and the highlight picks, worked out in one pass over the collection.
private struct CollectionSummary {
	private(set) var unopened = 0
	private(set) var drank = 0
	/// Most bottles recorded (unopened plus drank).
	private(set) var mostOwned: Item?
	/// Most bottles drank.
	private(set) var favorite: Item?
	/// The first wine with none left, otherwise the highest share drank per unopened bottle.
	private(set) var needToBuy: Item?
	/// The first wine never drank, otherwise the most unopened bottles per bottle drank.
	private(set) var tryNew: Item?

	var isEmpty: Bool { mostOwned == nil }

	/// Expects `wines` sorted by name: ties go to the wine that comes first.
	init(_ wines: some Sequence<Item>) {
		var mostRecorded = -1
		var mostDrank = -1
		var bestBuyRatio = -1.0
		var bestTryRatio = -1.0
		var firstOutOfStock: Item?
		var firstUndrunk: Item?

		for wine in wines {
			let quantity = Int(wine.wrappedQuantity)
			let drank = Int(wine.wrappedDrank)
			unopened += quantity
			self.drank += drank

			if quantity + drank > mostRecorded {
				mostRecorded = quantity + drank
				mostOwned = wine
			}
			if drank > mostDrank {
				mostDrank = drank
				favorite = wine
			}
			if quantity == 0 {
				firstOutOfStock = firstOutOfStock ?? wine
			} else if Double(drank) / Double(quantity) > bestBuyRatio {
				bestBuyRatio = Double(drank) / Double(quantity)
				needToBuy = wine
			}
			if drank == 0 {
				firstUndrunk = firstUndrunk ?? wine
			} else if Double(quantity) / Double(drank) > bestTryRatio {
				bestTryRatio = Double(quantity) / Double(drank)
				tryNew = wine
			}
		}
		needToBuy = firstOutOfStock ?? needToBuy
		tryNew = firstUndrunk ?? tryNew
	}
}

private struct SectionTitle: View {
	let title: String

	init(_ title: String) {
		self.title = title
	}

	var body: some View {
		Text(title)
			.font(.custom("Cochin-Bold", size: 22))
			.foregroundStyle(Color.accentColor)
	}
}

/// One bottle total, shown as a large number over a label.
private struct StatTile: View {
	let value: Int
	let label: String

	var body: some View {
		VStack(spacing: 2) {
			Text(value, format: .number)
				.font(.system(.title, design: .rounded, weight: .semibold))
				.foregroundStyle(Color.accentColor)
				.contentTransition(.numericText())
				.lineLimit(1)
				.minimumScaleFactor(0.6)
			Text(label)
				.font(.footnote)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 14)
		.background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
		.accessibilityElement(children: .combine)
	}
}

/// A wine picked for one of the highlights, with its photo and key details.
private struct WineHighlightCard: View {
	let title: String
	let systemImage: String
	@ObservedObject var wine: Item

	var body: some View {
		HStack(spacing: 14) {
			wine.thumbnail
				.resizable()
				.scaledToFill()
				.frame(width: 84, height: 84)
				.clipShape(RoundedRectangle(cornerRadius: 12))
				.accessibilityHidden(true)

			VStack(alignment: .leading, spacing: 3) {
				Label(title, systemImage: systemImage)
					.font(.caption.weight(.semibold))
					.foregroundStyle(Color.accentColor)
				Text(wine.wrappedName)
					.font(.custom("Cochin-Bold", size: 20))
					.foregroundStyle(.primary)
					.lineLimit(1)
				Text("\(wine.wrappedCreator) · \(wine.wrappedDomain)")
					.lineLimit(1)
				Text("\(wine.wineType?.name ?? "Unknown") · \(wine.editionLabel)")
					.lineLimit(1)
				Text("\(wine.wrappedQuantity) unopened · \(wine.wrappedDrank) drank")
					.lineLimit(1)
			}
			.font(.subheadline)
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding(12)
		.background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
		.accessibilityElement(children: .combine)
	}
}

#Preview {
	NavigationStack {
		HomeView(currentPerson: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
