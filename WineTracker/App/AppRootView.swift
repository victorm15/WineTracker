import SwiftUI
import CoreData

struct AppRootView: View {
	@EnvironmentObject var appState: AppState
    var body: some View {
		if let user = appState.currentPerson {
				MainTabView(currentPerson: user)
					// A new account gets a fresh tab view, and with it a fresh query cache.
					.id(user.objectID)
		}
		else {
			AuthView()
		}
    }
}

#Preview {
	
    AppRootView()
		.environment(\.managedObjectContext,PersistenceController.preview.container.viewContext)
		.environmentObject(AppState())
	
}
