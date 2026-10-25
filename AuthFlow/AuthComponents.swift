import SwiftUI

/// Shared styling for the text fields on the log in and sign up screens.
struct AuthFieldStyle: ViewModifier {
	var autocapitalization: TextInputAutocapitalization = .never

	func body(content: Content) -> some View {
		content
			.textFieldStyle(.roundedBorder)
			.textInputAutocapitalization(autocapitalization)
			.autocorrectionDisabled()
			.font(.title3)
	}
}

extension View {
	func authFieldStyle(autocapitalization: TextInputAutocapitalization = .never) -> some View {
		modifier(AuthFieldStyle(autocapitalization: autocapitalization))
	}
}

/// Gray-to-white gradient in light mode; system backgrounds in dark mode so text stays readable.
struct AuthBackground: View {
	@Environment(\.colorScheme) private var colorScheme

	var body: some View {
		LinearGradient(
			colors: colorScheme == .dark
				? [Color(.secondarySystemBackground), Color(.systemBackground)]
				: [Color.lighterGray, .white],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
		.ignoresSafeArea()
	}
}

struct AuthHeaderImage: View {
	var body: some View {
		Image(systemName: "person.circle.fill")
			.resizable()
			.frame(width: 100, height: 100)
			.foregroundStyle(Color.accentColor)
			.padding(30)
	}
}

/// A message shown after a log in or sign up attempt.
struct AuthAlert: Identifiable {
	let id = UUID()
	let title: String
	let message: String
	var buttonTitle = "OK"
	var onDismiss: () -> Void = {}
	/// Adds a second, cancel-style button when set.
	var secondaryButtonTitle: String? = nil
	var onSecondary: () -> Void = {}
}

extension View {
	func authAlert(_ alert: Binding<AuthAlert?>) -> some View {
		self.alert(
			alert.wrappedValue?.title ?? "",
			isPresented: Binding(
				get: { alert.wrappedValue != nil },
				set: { if !$0 { alert.wrappedValue = nil } }
			),
			presenting: alert.wrappedValue
		) { shown in
			Button(shown.buttonTitle) { shown.onDismiss() }
			if let secondaryButtonTitle = shown.secondaryButtonTitle {
				Button(secondaryButtonTitle, role: .cancel) { shown.onSecondary() }
			}
		} message: { shown in
			Text(shown.message)
		}
	}
}
