import SwiftUI


struct AppRootView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var appState: AppState
    var body: some View {
		if appState.isAuthenticated, let user = appState.currentPerson {
				MainTabView(currentPerson: user)
		}
		else {
			AuthTabView()
		}
		
		
    }
}

#Preview {
	
    AppRootView()
		.environment(\.managedObjectContext,PersistenceController.preview.container.viewContext)
		.environmentObject(AppState())
	
}
