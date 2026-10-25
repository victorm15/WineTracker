import SwiftUI

/// Left-aligned title for the current auth mode.
struct AuthHeader: View {
	let title: String

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.largeTitle.bold())
				.contentTransition(.opacity)
		}
		.foregroundStyle(Color.accentColor)
		.frame(maxWidth: .infinity, alignment: .leading)
		.accessibilityElement(children: .combine)
		.accessibilityAddTraits(.isHeader)
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

/// A text field with a leading icon and an optional message underneath.
/// A `hint` is shown in gray until there's an `error`, which replaces it in red.
struct AuthTextField<Field: Hashable>: View {
	let title: String
	let icon: String
	@Binding var text: String
	var focus: FocusState<Field?>.Binding
	let field: Field
	var error: String? = nil
	var hint: String? = nil
	var autocapitalization: TextInputAutocapitalization = .never

	var body: some View {
		AuthFieldLayout(icon: icon, error: error, hint: hint) {
			TextField(title, text: $text)
				.textInputAutocapitalization(autocapitalization)
				.focused(focus, equals: field)
		}
	}
}

/// A password field with the show/hide button inside it. Switching keeps the keyboard up.
struct AuthPasswordField<Field: Hashable>: View {
	let title: String
	@Binding var text: String
	var focus: FocusState<Field?>.Binding
	let field: Field
	var error: String? = nil
	var hint: String? = nil

	@State private var isRevealed = false

	var body: some View {
		AuthFieldLayout(icon: "lock", error: error, hint: hint) {
			HStack {
				// Always the same SecureField: swapping in a TextField to reveal the password
				// loses focus, and iOS clears a secure field when it's typed into again.
				// Revealing makes the field transparent (a clear text colour doesn't hide the
				// dots) and draws the text on top; tapping that text focuses the hidden field.
				SecureField(title, text: $text)
					.focused(focus, equals: field)
					.opacity(isRevealed ? 0 : 1)
					.overlay(alignment: .leading) {
						if isRevealed {
							Text(text.isEmpty ? title : text)
								.foregroundStyle(text.isEmpty ? Color.secondary : Color.primary)
								.lineLimit(1)
								.truncationMode(.head)
								.frame(maxWidth: .infinity, alignment: .leading)
								.contentShape(Rectangle())
								.onTapGesture { focus.wrappedValue = field }
								.accessibilityHidden(true)
						}
					}

				Button {
					isRevealed.toggle()
				} label: {
					Image(systemName: isRevealed ? "eye.slash" : "eye")
						.foregroundStyle(.secondary)
						.frame(width: 28, height: 28)
						.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
				.accessibilityLabel(isRevealed ? "Hide password" : "Show password")
			}
		}
	}
}

/// Shared look for the auth fields: icon, rounded box, and a message line underneath.
private struct AuthFieldLayout<Content: View>: View {
	let icon: String
	let error: String?
	let hint: String?
	@ViewBuilder let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			HStack(spacing: 12) {
				Image(systemName: icon)
					.foregroundStyle(.secondary)
					.frame(width: 22)
					.accessibilityHidden(true)
				content
					.textInputAutocapitalization(.never)
					.autocorrectionDisabled()
			}
			.font(.body)
			.padding(.horizontal, 14)
			.frame(minHeight: 52)
			.background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
			.overlay {
				RoundedRectangle(cornerRadius: 12)
					.strokeBorder(error == nil ? Color(.separator) : Color.red, lineWidth: 1)
			}

			if let message = error ?? hint {
				Text(message)
					.font(.footnote)
					.foregroundStyle(error == nil ? Color.secondary : Color.red)
					.padding(.leading, 4)
			}
		}
	}
}

/// Full-width filled button for the main action on each screen.
struct AuthPrimaryButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) private var isEnabled

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.headline)
			.foregroundStyle(.white)
			.frame(maxWidth: .infinity, minHeight: 52)
			.background(Color.accentColor.opacity(isEnabled ? 1 : 0.4), in: RoundedRectangle(cornerRadius: 14))
			.opacity(configuration.isPressed ? 0.85 : 1)
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}

/// Full-width tinted button for secondary actions, such as logging in with Face ID.
struct AuthSecondaryButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.headline)
			.foregroundStyle(Color.accentColor)
			.frame(maxWidth: .infinity, minHeight: 52)
			.background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
			.opacity(configuration.isPressed ? 0.7 : 1)
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
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
