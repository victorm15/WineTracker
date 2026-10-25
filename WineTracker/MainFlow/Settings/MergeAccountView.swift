import SwiftUI
import CoreData

/// Moves another account's wines into this one and deletes the other account,
/// after logging in to it and confirming.
struct MergeAccountView: View {
	@ObservedObject var person: Person
	@Environment(\.managedObjectContext) private var viewContext

	@State private var username = ""
	@State private var password = ""
	@State private var loginError: String?
	@State private var isChecking = false
	/// Set once the other account's password checks out; asks for confirmation.
	@State private var accountToMerge: Person?
	@State private var alert: AuthAlert?

	var body: some View {
		Form {
			Section {
				TextField("Username", text: $username)
					.textContentType(.username)
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
				SecureInputView("Password", text: $password)
					.textContentType(.password)
			} header: {
				Text("Other Account")
			} footer: {
				if let loginError {
					Text(loginError).foregroundStyle(.red)
				} else {
					Text("Its wines move into your collection, matching wines are combined, and the other account is deleted.")
				}
			}

			Section {
				Button(action: checkOtherAccount) {
					if isChecking {
						ProgressView()
					} else {
						Text("Merge Accounts")
					}
				}
				.disabled(username.isEmpty || password.isEmpty || isChecking)
			}
		}
		.navigationTitle("Merge Accounts")
		.navigationBarTitleDisplayMode(.inline)
		.onChange(of: username) { loginError = nil }
		.onChange(of: password) { loginError = nil }
		.onDisappear { password = "" }
		.confirmationDialog(
			"Merge @\(accountToMerge?.wrappedUsername ?? "")?",
			isPresented: Binding(
				get: { accountToMerge != nil },
				set: { if !$0 { accountToMerge = nil } }
			),
			titleVisibility: .visible,
			presenting: accountToMerge
		) { other in
			Button("Merge and Delete @\(other.wrappedUsername)", role: .destructive) {
				merge(other)
			}
		} message: { other in
			Text("\(other.itemsArray.count) \(other.itemsArray.count == 1 ? "wine" : "wines") will move to your collection and the @\(other.wrappedUsername) account will be deleted. This can't be undone.")
		}
		.authAlert($alert)
	}

	private func checkOtherAccount() {
		let other = Person.withUsername(username, in: viewContext)
		if other == person {
			loginError = "That's the account you're logged in to."
			return
		}
		isChecking = true
		Task {
			defer { isChecking = false }
			if await PasswordStore.verify(password, for: other?.accountID), let other {
				accountToMerge = other
			} else {
				loginError = "Incorrect username or password."
			}
		}
	}

	private func merge(_ other: Person) {
		let otherName = other.wrappedUsername
		accountToMerge = nil
		guard let count = person.absorb(other) else {
			alert = AuthAlert(title: "Couldn't Merge Accounts", message: "Something went wrong. Nothing was changed.")
			return
		}
		username = ""
		password = ""
		alert = AuthAlert(
			title: "Accounts Merged",
			message: "\(count) \(count == 1 ? "wine" : "wines") from @\(otherName) \(count == 1 ? "is" : "are") now in your collection."
		)
	}
}

#Preview {
	NavigationStack {
		MergeAccountView(person: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
