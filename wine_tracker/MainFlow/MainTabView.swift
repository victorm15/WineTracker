import SwiftUI

struct MainTabView: View {
	var currentPerson: Person
	@State private var selection: MainTab = .home

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
	}
}

#Preview {
	MainTabView(currentPerson: PersistenceController.previewPerson)
		.previewEnvironment()
}
