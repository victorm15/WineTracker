import SwiftUI

/// Deletes the account and its collection after the password is entered and the deletion confirmed.
struct DeleteAccountView: View {
	let person: Person
	@EnvironmentObject private var appState: AppState

	@State private var password = ""
	@State private var passwordWrong = false
	@State private var isChecking = false
	@State private var confirming = false
	@State private var deleteFailed = false

	private var wineCount: String {
		let count = person.itemsArray.count
		return "\(count) \(count == 1 ? "wine" : "wines")"
	}

	var body: some View {
		Form {
			Section {
				Text("Deleting @\(person.wrappedUsername) removes the account and the \(wineCount) in its collection. This can't be undone.")
			}

			Section {
				SecureInputView("Password", text: $password)
					.textContentType(.password)
			} footer: {
				if passwordWrong {
					Text("Incorrect password.").foregroundStyle(.red)
				} else {
					Text("Enter your password to confirm.")
				}
			}

			Section {
				Button(role: .destructive, action: checkPassword) {
					if isChecking {
						ProgressView()
					} else {
						Text("Delete Account")
					}
				}
				.disabled(password.isEmpty || isChecking)
			}
		}
		.navigationTitle("Delete Account")
		.navigationBarTitleDisplayMode(.inline)
		.onChange(of: password) { passwordWrong = false }
		.onDisappear { password = "" }
		.confirmationDialog("Delete @\(person.wrappedUsername)?", isPresented: $confirming, titleVisibility: .visible) {
			Button("Delete Account", role: .destructive, action: deleteAccount)
		} message: {
			Text("The account and its collection will be deleted. This can't be undone.")
		}
		.alert("Couldn't Delete Account", isPresented: $deleteFailed) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Something went wrong. Nothing was deleted.")
		}
	}

	private func checkPassword() {
		isChecking = true
		Task {
			defer { isChecking = false }
			if await PasswordStore.verify(password, for: person.accountID) {
				confirming = true
			} else {
				passwordWrong = true
			}
		}
	}

	private func deleteAccount() {
		// Log out first so no view draws the deleted account. Both changes happen before
		// SwiftUI updates, so a failed delete just restores the session.
		appState.currentPerson = nil
		if !person.deleteAccount() {
			appState.currentPerson = person
			deleteFailed = true
		}
	}
}

#Preview {
	NavigationStack {
		DeleteAccountView(person: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
