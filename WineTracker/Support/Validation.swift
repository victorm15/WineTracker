import Foundation

/// The rules for account details, shared by sign up and Edit Account. Each check returns the message
/// to show, or nil if the value is fine. Names and emails are checked with surrounding spaces removed,
/// the way they're saved.
enum Validation {
	static let minimumPasswordLength = 8
	static let passwordRule = "At least \(minimumPasswordLength) characters"

	static func trimmed(_ text: String) -> String {
		text.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	static func nameProblem(_ name: String) -> String? {
		trimmed(name).count >= 2 ? nil : "At least 2 characters"
	}

	/// Checks the username as it will be saved: trimmed and lowercased. Doesn't check whether it's taken.
	static func usernameProblem(_ username: String) -> String? {
		Person.normalizedUsername(username).count >= 2 ? nil : "At least 2 characters"
	}

	static func emailProblem(_ email: String) -> String? {
		let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: trimmed(email)) ? nil : "Enter a valid email"
	}

	/// Passwords are used exactly as typed, spaces included.
	static func passwordProblem(_ password: String) -> String? {
		password.count >= minimumPasswordLength ? nil : passwordRule
	}
}
