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
		if !isValidField(text: normalizedUsername) {
			return "At least 2 characters"
		}
		// Your own username, in any capitalisation, isn't "taken".
		if let owner = Person.withUsername(normalizedUsername, in: viewContext), owner != person {
			return "This username is taken"
		}
		return nil
	}

	private var nameError: String? {
		isValidField(text: trimmed(firstName)) && isValidField(text: trimmed(lastName))
			? nil
			: "First and last name need at least 2 characters each"
	}

	private var emailError: String? {
		isValidEmail(email: trimmed(email)) ? nil : "Enter a valid email"
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
		text.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}

#Preview {
	NavigationStack {
		EditAccountView(person: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
