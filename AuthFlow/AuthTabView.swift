import SwiftUI

struct AuthTabView: View {
    var body: some View {
		
		
		TabView() {
			
			SignUpView()
				.tabItem {
					Label("Sign Up", systemImage: "person.fill.badge.plus")
				}
			
			LoginView()
				.tabItem { Label("Log In", systemImage: "person.badge.key.fill") }
			
			
		}
		
		
		
		
		
		
		
		
    }
}

#Preview {
    AuthTabView()
}
