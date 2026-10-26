import SwiftUI
import CoreData

/// Edits the account's username, name and email, with the same rules as sign up.
struct EditAccountView: View {
	@ObservedObject var person: Person
	@Environment(\.managedObjectContext) private var viewContext
	@Environment(\.dismiss) private var dismiss

	@State private var username = ""
	@State private var firstName = ""
	@State private var lastName = ""
	@State private var email = ""
	@State private var hasLoaded = false
	@State private var saveFailed = false
	/// Whether the entered username belongs to another account, checked once typing pauses.
	@State private var usernameTaken = false

	var body: some View {
		Form {
			Section {
				TextField("Username", text: $username)
					.textContentType(.username)
					.textInputAutocapitalization(.never)
			} header: {
				Text("Username")
			} footer: {
				if let usernameError {
					Text(usernameError).foregroundStyle(.red)
				}
			}

			Section {
				TextField("First Name", text: $firstName)
					.textContentType(.givenName)
				TextField("Last Name", text: $lastName)
					.textContentType(.familyName)
			} header: {
				Text("Name")
			} footer: {
				if let nameError {
					Text(nameError).foregroundStyle(.red)
				}
			}
			.textInputAutocapitalization(.words)

			Section {
				TextField("Email", text: $email)
					.keyboardType(.emailAddress)
					.textContentType(.emailAddress)
					.textInputAutocapitalization(.never)
			} header: {
				Text("Email")
			} footer: {
				if let emailError {
					Text(emailError).foregroundStyle(.red)
				}
			}
		}
		.autocorrectionDisabled()
		.navigationTitle("Edit Account")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				Button("Save", action: save)
					.disabled(!hasChanges || !isValid)
			}
		}
		.onAppear(perform: load)
		.task(id: normalizedUsername) {
			usernameTaken = false
			// Looking the username up on every redraw would query the database several times a keystroke.
			guard (try? await Task.sleep(for: .milliseconds(300))) != nil else { return }
			usernameTaken = isTaken(normalizedUsername)
		}
		.alert("Couldn't Save Changes", isPresented: $saveFailed) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Something went wrong saving your account. Nothing was changed.")
		}
	}

	private var normalizedUsername: String {
		Person.normalizedUsername(username)
	}

	private var usernameError: String? {
		Validation.usernameProblem(username) ?? (usernameTaken ? "This username is taken" : nil)
	}

	private var nameError: String? {
		Validation.nameProblem(firstName) == nil && Validation.nameProblem(lastName) == nil
			? nil
			: "First and last name need at least 2 characters each"
	}

	private var emailError: String? {
		Validation.emailProblem(email)
	}

	/// Your own username, in any capitalisation, isn't "taken".
	private func isTaken(_ username: String) -> Bool {
		guard let owner = Person.withUsername(username, in: viewContext) else { return false }
		return owner != person
	}

	private var isValid: Bool {
		usernameError == nil && nameError == nil && emailError == nil
	}

	private var hasChanges: Bool {
		normalizedUsername != person.wrappedUsername
			|| trimmed(firstName) != person.wrappedFirstName
			|| trimmed(lastName) != person.wrappedLastName
			|| trimmed(email) != person.wrappedEmail
	}

	private func load() {
		guard !hasLoaded else { return }
		hasLoaded = true
		username = person.wrappedUsername
		firstName = person.wrappedFirstName
		lastName = person.wrappedLastName
		email = person.wrappedEmail
	}

	private func save() {
		// The check while typing may not have run yet.
		if isTaken(normalizedUsername) {
			usernameTaken = true
			return
		}
		person.setUsername(newUsername: username)
		person.setFirstName(newFirstName: trimmed(firstName))
		person.setLastName(newLastName: trimmed(lastName))
		person.setEmail(newEmail: trimmed(email))
		if viewContext.saveOrRollback() {
			dismiss()
		} else {
			saveFailed = true
		}
	}

	private func trimmed(_ text: String) -> String {
		Validation.trimmed(text)
	}
}

#Preview {
	NavigationStack {
		EditAccountView(person: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
