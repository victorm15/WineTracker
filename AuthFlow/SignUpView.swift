import SwiftUI
import CoreData

struct SignUpView: View {

	/// Called after the user dismisses the "account created" message.
	var onAccountCreated: () -> Void = {}

	@Environment(\.managedObjectContext) private var viewContext

	@State private var email = ""
	@State private var username = ""
	@State private var password = ""
	@State private var firstName = ""
	@State private var lastName = ""

	@State private var alert: AuthAlert?
	@State private var isCreating = false
	@FocusState private var focusedField: Field?

	private enum Field {
		case firstName, lastName, email, username, password
	}

	private enum SignUpError: Error {
		case passwordNotSaved
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 12) {
				AuthHeaderImage()
				HStack {
					TextField("First Name", text: $firstName)
						.authFieldStyle(autocapitalization: .words)
						.textContentType(.givenName)
						.focused($focusedField, equals: .firstName)
						.submitLabel(.next)
						.onSubmit { focusedField = .lastName }

					TextField("Last Name", text: $lastName)
						.authFieldStyle(autocapitalization: .words)
						.textContentType(.familyName)
						.focused($focusedField, equals: .lastName)
						.submitLabel(.next)
						.onSubmit { focusedField = .email }
				}
				TextField("Email", text: $email)
					.authFieldStyle()
					.keyboardType(.emailAddress)
					.textContentType(.emailAddress)
					.focused($focusedField, equals: .email)
					.submitLabel(.next)
					.onSubmit { focusedField = .username }
				TextField("Username", text: $username)
					.authFieldStyle()
					.textContentType(.username)
					.focused($focusedField, equals: .username)
					.submitLabel(.next)
					.onSubmit { focusedField = .password }
				SecureInputView("Password", text: $password)
					.authFieldStyle()
					.textContentType(.newPassword)
					.focused($focusedField, equals: .password)
					.submitLabel(.go)
					.onSubmit(createAccount)
				Button(action: createAccount) {
					if isCreating {
						ProgressView()
							.tint(.white)
					} else {
						Text("Make Account")
					}
				}
				.buttonStyle(AccountButton())
				.font(.headline)
				.disabled(isCreating)
			}
			.padding()
		}
		.defaultScrollAnchor(.center, for: .alignment)
		.scrollBounceBehavior(.basedOnSize)
		.scrollDismissesKeyboard(.interactively)
		.background { AuthBackground() }
		.authAlert($alert)
	}

	private func createAccount() {
		guard !isCreating else { return }
		guard isValidField(text: firstName),
			  isValidField(text: lastName),
			  isValidField(text: Person.normalizedUsername(username)),
			  isValidPassword(password),
			  isValidEmail(email: email) else {
			alert = AuthAlert(
				title: "Invalid field entries",
				message: "Names and username need at least 2 characters, the password at least \(minimumPasswordLength), and the email must be valid."
			)
			return
		}
		guard !Person.isUsernameTaken(username, in: viewContext) else {
			alert = AuthAlert(title: "Username Taken", message: "Please choose another username.")
			return
		}

		isCreating = true
		Task {
			defer { isCreating = false }
			let newAccount = Person(context: viewContext)
			newAccount.setUsername(newUsername: username)
			newAccount.setFirstName(newFirstName: firstName)
			newAccount.setLastName(newLastName: lastName)
			newAccount.setEmail(newEmail: email)
			do {
				// The password hash is keyed by the account ID, so it has to be permanent first.
				try viewContext.obtainPermanentIDs(for: [newAccount])
				guard await PasswordStore.save(password, for: newAccount.accountID) else {
					throw SignUpError.passwordNotSaved
				}
				try viewContext.save()
			} catch {
				PasswordStore.delete(for: newAccount.accountID)
				viewContext.rollback()
				alert = AuthAlert(title: "Couldn't create account", message: "Something went wrong saving your account. Please try again.")
				return
			}

			focusedField = nil
			clearForm()
			alert = AuthAlert(
				title: "Account successfully made",
				message: "Please log in.",
				buttonTitle: "Go to Log In",
				onDismiss: onAccountCreated
			)
		}
	}

	private func clearForm() {
		email = ""
		username = ""
		password = ""
		firstName = ""
		lastName = ""
	}
}

#Preview {
	SignUpView()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
