import SwiftUI

/// Changes the account's password after checking the current one.
struct ChangePasswordView: View {
	let person: Person
	@Environment(\.dismiss) private var dismiss

	@State private var currentPassword = ""
	@State private var newPassword = ""
	@State private var currentPasswordWrong = false
	@State private var isSaving = false
	@State private var alert: AuthAlert?

	private var canSubmit: Bool {
		!currentPassword.isEmpty && Validation.passwordProblem(newPassword) == nil && !isSaving
	}

	var body: some View {
		Form {
			Section {
				SecureInputView("Current Password", text: $currentPassword)
					.textContentType(.password)
			} footer: {
				if currentPasswordWrong {
					Text("Incorrect password.").foregroundStyle(.red)
				}
			}

			Section {
				SecureInputView("New Password", text: $newPassword)
			} footer: {
				Text(Validation.passwordRule)
					.foregroundStyle(!newPassword.isEmpty && Validation.passwordProblem(newPassword) != nil ? Color.red : Color.secondary)
			}

			Section {
				Button(action: changePassword) {
					if isSaving {
						ProgressView()
					} else {
						Text("Change Password")
					}
				}
				.disabled(!canSubmit)
			}
		}
		.navigationTitle("Change Password")
		.navigationBarTitleDisplayMode(.inline)
		.onChange(of: currentPassword) { currentPasswordWrong = false }
		.authAlert($alert)
	}

	private func changePassword() {
		guard canSubmit else { return }
		isSaving = true
		Task {
			defer { isSaving = false }
			guard await PasswordStore.verify(currentPassword, for: person.accountID) else {
				currentPasswordWrong = true
				return
			}
			guard await PasswordStore.save(newPassword, for: person.accountID) else {
				alert = AuthAlert(title: "Couldn't Change Password", message: "Something went wrong. Your current password still works.")
				return
			}
			currentPassword = ""
			newPassword = ""
			alert = AuthAlert(
				title: "Password Changed",
				message: "Use your new password next time you log in.",
				onDismiss: { dismiss() }
			)
		}
	}
}

#Preview {
	NavigationStack {
		ChangePasswordView(person: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
