import SwiftUI

struct MainTabView: View {
	var currentPerson: Person
	@State private var selection: MainTab = .home
	/// Lives as long as this account is logged in.
	@State private var queryCache: QueryCache

	init(currentPerson: Person) {
		self.currentPerson = currentPerson
		_queryCache = State(initialValue: QueryCache(person: currentPerson))
	}

	enum MainTab: Hashable {
		case collection, home, addWine, settings
	}

	var body: some View {
		TabView(selection: $selection) {
			Tab("Home", systemImage: "house.fill", value: .home) {
				NavigationStack {
					HomeView(currentPerson: currentPerson, onAddWine: { selection = .addWine })
				}
			}
			Tab("Collection", systemImage: "list.bullet", value: .collection) {
				NavigationStack { CollectionView(currentPerson: currentPerson) }
			}
			Tab("Add Wine", systemImage: "plus.circle.fill", value: .addWine) {
				NavigationStack { AddWineView(currentPerson: currentPerson) }
			}
			Tab("Settings", systemImage: "gear", value: .settings) {
				NavigationStack { SettingsView(currentPerson: currentPerson) }
			}
		}
		.environment(queryCache)
	}
}

#Preview {
	MainTabView(currentPerson: PersistenceController.previewPerson)
		.previewEnvironment()
}
