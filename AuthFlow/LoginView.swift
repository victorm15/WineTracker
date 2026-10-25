import SwiftUI
import CoreData

struct LoginView: View {

	@State private var usernameAttempt = ""
	@State private var passwordAttempt = ""

	@State private var alert: AuthAlert?
	@State private var loginError: String?
	@State private var failedAttempts = 0
	@State private var isLoggingIn = false
	/// Re-read when the view appears, since Face ID can be turned on or off in Settings.
	@State private var biometricAccount: Person?
	@FocusState private var focusedField: Field?
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var appState: AppState

	private enum Field {
		case username, password
	}

	private var canSubmit: Bool {
		!usernameAttempt.isEmpty && !passwordAttempt.isEmpty && !isLoggingIn
	}

	var body: some View {
		VStack(spacing: 14) {
			AuthTextField(title: "Username", icon: "person", text: $usernameAttempt,
						  focus: $focusedField, field: .username)
				.textContentType(.username)
				.submitLabel(.next)
				.onSubmit { focusedField = .password }
			AuthPasswordField(title: "Password", text: $passwordAttempt,
							  focus: $focusedField, field: .password, error: loginError)
				.textContentType(.password)
				.submitLabel(.go)
				.onSubmit(logIn)

			Button(action: logIn) {
				if isLoggingIn {
					ProgressView()
						.tint(.white)
				} else {
					Text("Log In")
				}
			}
			.buttonStyle(AuthPrimaryButtonStyle())
			.disabled(!canSubmit)
			.padding(.top, 8)

			if let biometricAccount {
				Button(action: logInWithBiometrics) {
					Label("Log in as \(biometricAccount.wrappedUsername)", systemImage: BiometricLogin.biometryIcon)
				}
				.buttonStyle(AuthSecondaryButtonStyle())
				.disabled(isLoggingIn)
				.accessibilityHint("Uses \(BiometricLogin.biometryName)")
			}
		}
		.sensoryFeedback(.error, trigger: failedAttempts)
		.authAlert($alert)
		.onAppear(perform: refreshBiometricAccount)
	}

	private func logIn() {
		guard canSubmit else { return }
		loginError = nil
		isLoggingIn = true
		Task {
			defer { isLoggingIn = false }
			let person = Person.withUsername(usernameAttempt, in: viewContext)
			guard await PasswordStore.verify(passwordAttempt, for: person?.accountID), let person else {
				passwordAttempt = ""
				loginError = "Incorrect username or password."
				failedAttempts += 1
				focusedField = .password
				return
			}
			offerBiometricLogin(thenLogIn: person)
		}
	}

	/// After a password login, offers to remember the account for Face ID if it isn't already.
	private func offerBiometricLogin(thenLogIn person: Person) {
		guard BiometricLogin.isAvailable, !BiometricLogin.isEnabled(for: person) else {
			complete(person)
			return
		}
		let name = BiometricLogin.biometryName
		alert = AuthAlert(
			title: "Use \(name)?",
			message: "Log in to this account with \(name) next time instead of your password.",
			buttonTitle: "Use \(name)",
			onDismiss: {
				BiometricLogin.enable(for: person)
				complete(person)
			},
			secondaryButtonTitle: "Not Now",
			onSecondary: { complete(person) }
		)
	}

	private func logInWithBiometrics() {
		guard !isLoggingIn else { return }
		isLoggingIn = true
		Task {
			defer { isLoggingIn = false }
			switch await BiometricLogin.authenticate() {
			case .success(let accountID):
				if let person = Person.withAccountID(accountID, in: viewContext) {
					complete(person)
				} else {
					BiometricLogin.disable()
					refreshBiometricAccount()
					alert = AuthAlert(title: "Account not found", message: "Please log in with your username and password.")
				}
			case .unavailable:
				refreshBiometricAccount()
				alert = AuthAlert(
					title: "\(BiometricLogin.biometryName) login turned off",
					message: "Your \(BiometricLogin.biometryName) settings changed. Please log in with your password."
				)
			case .cancelled:
				break
			}
		}
	}

	// Switching isAuthenticated replaces the auth screen with MainTabView.
	private func complete(_ person: Person) {
		appState.currentPerson = person
		appState.isAuthenticated = true
	}

	private func refreshBiometricAccount() {
		biometricAccount = BiometricLogin.rememberedAccountID.flatMap { Person.withAccountID($0, in: viewContext) }
	}
}

#Preview {
	LoginView()
		.padding()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		.environmentObject(AppState())
}
