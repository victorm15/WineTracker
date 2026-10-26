import SwiftUI

// Show/hide for password fields. The SecureField is never swapped for a TextField: that loses
// focus, and iOS clears a secure field when it's typed into again. Revealing makes the field
// transparent instead (a clear text colour doesn't hide the dots) and draws the text on top.

extension View {
	/// Draws `text` over this secure field while `isRevealed`; tapping it calls `focus`.
	func revealing(_ text: String, placeholder: String, isRevealed: Bool, focus: @escaping () -> Void) -> some View {
		opacity(isRevealed ? 0 : 1)
			.overlay(alignment: .leading) {
				if isRevealed {
					Text(text.isEmpty ? placeholder : text)
						.foregroundStyle(text.isEmpty ? Color.secondary : Color.primary)
						.lineLimit(1)
						.truncationMode(.head)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						.onTapGesture(perform: focus)
						.accessibilityHidden(true)
				}
			}
	}
}

/// The eye button that shows or hides a password.
struct RevealButton: View {
	@Binding var isRevealed: Bool

	var body: some View {
		Button {
			isRevealed.toggle()
		} label: {
			Image(systemName: isRevealed ? "eye.slash" : "eye")
				.foregroundStyle(.secondary)
				.frame(width: 28, height: 28)
				.contentShape(Rectangle())
		}
		.buttonStyle(.borderless)
		.tint(.secondary)
		.accessibilityLabel(isRevealed ? "Hide password" : "Show password")
	}
}

/// A password field with a show/hide button, for use in forms.
struct SecureInputView: View {
	let title: String
	@Binding var text: String
	@State private var isRevealed = false
	@FocusState private var isFocused: Bool

	init(_ title: String, text: Binding<String>) {
		self.title = title
		self._text = text
	}

	var body: some View {
		HStack {
			SecureField(title, text: $text)
				.focused($isFocused)
				.revealing(text, placeholder: title, isRevealed: isRevealed) { isFocused = true }
			RevealButton(isRevealed: $isRevealed)
		}
	}
}
