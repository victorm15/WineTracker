import SwiftUI
import CoreData

struct LoginView: View {

	@State private var usernameAttempt = ""
	@State private var passwordAttempt = ""

	@State private var alert: AuthAlert?
	@State private var isLoggingIn = false
	/// Re-read when the view appears, since Face ID can be turned on or off in Settings.
	@State private var biometricAccount: Person?
	@FocusState private var focusedField: Field?
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var appState: AppState

	private enum Field {
		case username, password
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 12) {
				AuthHeaderImage()
				TextField("Username", text: $usernameAttempt)
					.authFieldStyle()
					.textContentType(.username)
					.focused($focusedField, equals: .username)
					.submitLabel(.next)
					.onSubmit { focusedField = .password }
				SecureInputView("Password", text: $passwordAttempt)
					.authFieldStyle()
					.textContentType(.password)
					.focused($focusedField, equals: .password)
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
				.buttonStyle(AccountButton())
				.font(.headline)
				.disabled(isLoggingIn)

				if let biometricAccount {
					Button(action: logInWithBiometrics) {
						Label("Log in as \(biometricAccount.wrappedUsername) with \(BiometricLogin.biometryName)",
							  systemImage: BiometricLogin.biometryIcon)
					}
					.font(.subheadline)
					.padding(.top, 8)
					.disabled(isLoggingIn)
				}
			}
			.padding()
		}
		.defaultScrollAnchor(.center, for: .alignment)
		.scrollBounceBehavior(.basedOnSize)
		.scrollDismissesKeyboard(.interactively)
		.background { AuthBackground() }
		.authAlert($alert)
		.onAppear(perform: refreshBiometricAccount)
	}

	private func logIn() {
		guard !isLoggingIn else { return }
		isLoggingIn = true
		Task {
			defer { isLoggingIn = false }
			let person = Person.withUsername(usernameAttempt, in: viewContext)
			guard await PasswordStore.verify(passwordAttempt, for: person?.accountID), let person else {
				passwordAttempt = ""
				alert = AuthAlert(title: "Log in failure", message: "Please check credentials.")
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

	// Switching isAuthenticated replaces this view with MainTabView.
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
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
		.environmentObject(AppState())
}
