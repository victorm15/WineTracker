import SwiftUI
import CoreData

struct AppRootView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var appState: AppState
    var body: some View {
		if let user = appState.currentPerson {
				MainTabView(currentPerson: user)
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
