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
	/// Fields the user has left; their errors show from then on.
	@State private var touchedFields: Set<Field> = []
	/// Normalized usernames found to be taken, checked when the username field is left.
	@State private var takenUsernames: Set<String> = []
	@State private var failedAttempts = 0
	@FocusState private var focusedField: Field?

	private enum Field: CaseIterable {
		case firstName, lastName, email, username, password
	}

	private enum SignUpError: Error {
		case passwordNotSaved
	}

	private var isFormValid: Bool {
		Field.allCases.allSatisfy { problem(with: $0) == nil }
	}

	var body: some View {
		VStack(spacing: 14) {
			HStack(alignment: .top, spacing: 12) {
				AuthTextField(title: "First Name", icon: "person", text: $firstName,
							  focus: $focusedField, field: .firstName,
							  error: error(for: .firstName), autocapitalization: .words)
					.textContentType(.givenName)
					.submitLabel(.next)
					.onSubmit { focusedField = .lastName }
				AuthTextField(title: "Last Name", icon: "person", text: $lastName,
							  focus: $focusedField, field: .lastName,
							  error: error(for: .lastName), autocapitalization: .words)
					.textContentType(.familyName)
					.submitLabel(.next)
					.onSubmit { focusedField = .email }
			}
			AuthTextField(title: "Email", icon: "envelope", text: $email,
						  focus: $focusedField, field: .email, error: error(for: .email))
				.keyboardType(.emailAddress)
				.textContentType(.emailAddress)
				.submitLabel(.next)
				.onSubmit { focusedField = .username }
			AuthTextField(title: "Username", icon: "at", text: $username,
						  focus: $focusedField, field: .username, error: error(for: .username))
				.textContentType(.username)
				.submitLabel(.next)
				.onSubmit { focusedField = .password }
			// .password rather than .newPassword: iOS's automatic strong-password
			// overlay was dropping typed characters in this field.
			AuthPasswordField(title: "Password", text: $password,
							  focus: $focusedField, field: .password,
							  error: error(for: .password),
							  hint: Validation.passwordRule)
				.textContentType(.password)
				.submitLabel(.go)
				.onSubmit(createAccount)

			Button(action: createAccount) {
				if isCreating {
					ProgressView()
						.tint(.white)
				} else {
					Text("Create Account")
				}
			}
			.buttonStyle(AuthPrimaryButtonStyle())
			.disabled(!isFormValid || isCreating)
			.padding(.top, 8)
		}
		.onChange(of: focusedField) { previous, _ in
			// Leaving an empty field doesn't count: that's also what happens when the form is
			// cleared after an account is created. Create Account marks every field instead.
			guard let previous, !text(of: previous).isEmpty else { return }
			touchedFields.insert(previous)
			if previous == .username {
				checkUsernameAvailability()
			}
		}
		.sensoryFeedback(.error, trigger: failedAttempts)
		.authAlert($alert)
	}

	private func text(of field: Field) -> String {
		switch field {
		case .firstName: firstName
		case .lastName: lastName
		case .email: email
		case .username: username
		case .password: password
		}
	}

	/// The problem with a field, shown only once the user has left it.
	private func error(for field: Field) -> String? {
		touchedFields.contains(field) ? problem(with: field) : nil
	}

	private func problem(with field: Field) -> String? {
		switch field {
		case .firstName:
			return Validation.nameProblem(firstName)
		case .lastName:
			return Validation.nameProblem(lastName)
		case .email:
			return Validation.emailProblem(email)
		case .username:
			if let problem = Validation.usernameProblem(username) { return problem }
			return takenUsernames.contains(Person.normalizedUsername(username)) ? "This username is taken" : nil
		case .password:
			return Validation.passwordProblem(password)
		}
	}

	private func checkUsernameAvailability() {
		if Person.isUsernameTaken(username, in: viewContext) {
			takenUsernames.insert(Person.normalizedUsername(username))
		}
	}

	private func createAccount() {
		guard !isCreating else { return }
		checkUsernameAvailability()
		guard isFormValid else {
			touchedFields = Set(Field.allCases)
			failedAttempts += 1
			return
		}

		isCreating = true
		Task {
			defer { isCreating = false }
			let newAccount = Person(context: viewContext)
			newAccount.setUsername(newUsername: username)
			newAccount.setFirstName(newFirstName: Validation.trimmed(firstName))
			newAccount.setLastName(newLastName: Validation.trimmed(lastName))
			newAccount.setEmail(newEmail: Validation.trimmed(email))
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
				title: "Account created",
				message: "You can now log in.",
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
		touchedFields = []
	}
}

#Preview {
	SignUpView()
		.padding()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
