import SwiftUI

// Form pieces shared by the add and edit wine pages.

extension WineType {
	/// Fits a segmented control.
	var shortName: String {
		switch self {
		case .red: "Red"
		case .white: "White"
		case .champagne: "Champagne"
		}
	}
}

/// A labelled bottle count that can be typed or changed with a stepper.
struct BottleCountRow: View {
	let title: String
	@Binding var text: String
	let maximum: Int

	var body: some View {
		HStack {
			Text(title)
			Spacer()
			TextField("0", text: $text)
				.keyboardType(.numberPad)
				.multilineTextAlignment(.trailing)
				.monospacedDigit()
				.frame(width: 48)
				.digitsOnly($text, maxLength: 3)
			Stepper(title, value: Binding(
				get: { Int(text) ?? 0 },
				set: { text = String($0) }
			), in: 0...maximum)
			.labelsHidden()
		}
	}
}

/// A red validation message shown under a form section.
struct ErrorText: View {
	let message: String

	init(_ message: String) {
		self.message = message
	}

	var body: some View {
		Text(message)
			.foregroundStyle(.red)
	}
}

extension View {
	/// Keeps only ASCII digits in `text`, up to `maxLength` of them, including pasted text.
	func digitsOnly(_ text: Binding<String>, maxLength: Int) -> some View {
		onChange(of: text.wrappedValue) { _, newValue in
			let digits = String(newValue.filter { $0.isASCII && $0.isNumber }.prefix(maxLength))
			if digits != newValue {
				text.wrappedValue = digits
			}
		}
	}
}
