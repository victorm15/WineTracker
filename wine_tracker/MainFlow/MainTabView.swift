import SwiftUI





struct MainTabView: View {
	
	
	var currentPerson: Person
	@State private var selection: MainTab = .collection
	
	enum MainTab: Hashable {
		case collection, account, home, addWine, settings
	}
	
	
    var body: some View {
		TabView{
			NavigationStack { CollectionView(currentPerson: currentPerson) }
				.tag(MainTab.collection)
				.tabItem { Label("Collection", systemImage: "list.bullet") }
			NavigationStack { AccountView(currentPerson: currentPerson) }
				.tag(MainTab.account)
				.tabItem { Label("Account", systemImage: "person.fill") }
			NavigationStack { HomeView(currentPerson: currentPerson) }
				.tag(MainTab.home)
				.tabItem { Label("Home", systemImage: "house.fill")}
			NavigationStack { AddWineView(currentPerson: currentPerson) }
				.tag(MainTab.addWine)
				.tabItem{ Label("Add Wine", systemImage: "plus.circle.fill")}
			NavigationStack { SettingsView(currentPerson: currentPerson) }
				.tag(MainTab.settings)
				.tabItem{ Label("Settings", systemImage: "gear")}
			
		}
    }
	
}
