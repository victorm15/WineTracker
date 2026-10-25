import SwiftUI
import CoreData

struct AuthTabView: View {
	private enum AuthTab {
		case logIn, signUp
	}

	@State private var selection = AuthTab.logIn

	var body: some View {
		TabView(selection: $selection) {
			Tab("Log In", systemImage: "person.badge.key.fill", value: AuthTab.logIn) {
				LoginView()
			}
			Tab("Sign Up", systemImage: "person.fill.badge.plus", value: AuthTab.signUp) {
				SignUpView(onAccountCreated: { selection = .logIn })
			}
		}
	}
}

#Preview {
	AuthTabView()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		.environmentObject(AppState())
}
