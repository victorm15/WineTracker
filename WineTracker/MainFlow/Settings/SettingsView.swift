import SwiftUI

struct SettingsView: View {
	@ObservedObject var currentPerson: Person
	@EnvironmentObject private var appState: AppState

	@State private var biometricLoginOn = false
	@State private var confirmingLogOut = false

	var body: some View {
		Form {
			Section("Account") {
				LabeledContent("Name", value: "\(currentPerson.wrappedFirstName) \(currentPerson.wrappedLastName)")
				LabeledContent("Username", value: "@\(currentPerson.wrappedUsername)")
				LabeledContent("Email", value: currentPerson.wrappedEmail)
				NavigationLink("Edit Account") {
					EditAccountView(person: currentPerson)
				}
			}

			Section("Security") {
				NavigationLink("Change Password") {
					ChangePasswordView(person: currentPerson)
				}
				if BiometricLogin.isAvailable {
					// A custom binding so setting the initial value on appear doesn't re-enable it.
					Toggle("Log In with \(BiometricLogin.biometryName)", isOn: Binding(
						get: { biometricLoginOn },
						set: setBiometricLogin
					))
				}
			}

			Section {
				NavigationLink("Merge Another Account") {
					MergeAccountView(person: currentPerson)
				}
			} footer: {
				Text("Move another account's wines into yours, then delete that account.")
			}

			Section {
				Button("Log Out") {
					confirmingLogOut = true
				}
				NavigationLink {
					DeleteAccountView(person: currentPerson)
				} label: {
					Text("Delete Account")
						.foregroundStyle(.red)
				}
			}
		}
		.navigationTitle("")
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Settings")
					.font(.custom("Cochin", size: 34))
					.foregroundColor(.accentColor)
			}
		}
		.onAppear {
			biometricLoginOn = BiometricLogin.isEnabled(for: currentPerson)
		}
		.confirmationDialog("Log out of @\(currentPerson.wrappedUsername)?", isPresented: $confirmingLogOut, titleVisibility: .visible) {
			Button("Log Out", role: .destructive) {
				appState.currentPerson = nil
			}
		}
	}

	private func setBiometricLogin(_ isOn: Bool) {
		if isOn {
			biometricLoginOn = BiometricLogin.enable(for: currentPerson)
		} else {
			BiometricLogin.forget(accountID: currentPerson.accountID)
			biometricLoginOn = false
		}
	}
}

#Preview {
	NavigationStack {
		SettingsView(currentPerson: PersistenceController.previewPerson)
	}
	.previewEnvironment()
}
