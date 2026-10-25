import SwiftUI
import CoreData

/// Log in and sign up on one screen, switched with a segmented control.
struct AuthView: View {
	private enum Mode: String, CaseIterable {
		case logIn = "Log In"
		case signUp = "Sign Up"

		var title: String {
			switch self {
			case .logIn: "Welcome back"
			case .signUp: "Create an account"
			}
		}
	}

	@State private var mode = Mode.logIn

	var body: some View {
		ScrollView {
			VStack(spacing: 28) {
				AuthHeader(title: mode.title)
					.padding(.top, 24)

				Picker("Mode", selection: $mode.animation(.easeInOut(duration: 0.2))) {
					ForEach(Mode.allCases, id: \.self) { mode in
						Text(mode.rawValue)
					}
				}
				.pickerStyle(.segmented)
				.labelsHidden()

				switch mode {
				case .logIn:
					LoginView()
						.transition(.opacity)
				case .signUp:
					SignUpView(onAccountCreated: {
						withAnimation { mode = .logIn }
					})
					.transition(.opacity)
				}
			}
			.padding(.horizontal, 24)
			.padding(.vertical, 32)
			.frame(maxWidth: 480)
			.frame(maxWidth: .infinity)
		}
		.scrollBounceBehavior(.basedOnSize)
		.scrollDismissesKeyboard(.interactively)
		.background { AuthBackground() }
	}
}

#Preview {
	AuthView()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		.environmentObject(AppState())
}
