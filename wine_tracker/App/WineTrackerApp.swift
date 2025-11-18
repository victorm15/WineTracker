import SwiftUI

@main
    struct WineTrackerApp: App {
    let persistenceController = PersistenceController.shared
	@StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(appState)
                .statusBar(hidden: true)
        }
    }
}
