import Foundation
import LocalAuthentication
import Security

/// Remembers one account so it can log in with Face ID / Touch ID instead of its password.
/// The account ID lives in a Keychain item that iOS only hands back after a successful biometric
/// check, and that is invalidated if the enrolled faces or fingerprints change.
enum BiometricLogin {

	enum Outcome {
		case success(accountID: String)
		case cancelled
		/// The Keychain item is gone, e.g. because enrolled biometrics changed. Biometric login is now off.
		case unavailable
	}

	private static let service = "VictorM.wine-tracker.biometric-login"
	private static let account = "remembered-account"
	/// Which account is set up, for display only. Logging in always reads the protected Keychain item.
	private static let rememberedAccountKey = "biometricLoginAccountID"

	static var isAvailable: Bool {
		LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
	}

	static var biometryName: String {
		switch currentBiometryType {
		case .touchID: "Touch ID"
		case .opticID: "Optic ID"
		default: "Face ID"
		}
	}

	static var biometryIcon: String {
		switch currentBiometryType {
		case .touchID: "touchid"
		case .opticID: "opticid"
		default: "faceid"
		}
	}

	/// The account biometric login is set up for, if biometrics can be used right now.
	static var rememberedAccountID: String? {
		isAvailable ? UserDefaults.standard.string(forKey: rememberedAccountKey) : nil
	}

	static func isEnabled(for person: Person) -> Bool {
		rememberedAccountID == person.accountID
	}

	/// Replaces any previously remembered account.
	@discardableResult
	static func enable(for person: Person) -> Bool {
		guard let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .biometryCurrentSet, nil),
			  Keychain.set(Data(person.accountID.utf8), service: service, account: account, accessControl: access) else {
			return false
		}
		UserDefaults.standard.set(person.accountID, forKey: rememberedAccountKey)
		return true
	}

	static func disable() {
		Keychain.delete(service: service, account: account)
		UserDefaults.standard.removeObject(forKey: rememberedAccountKey)
	}

	/// Turns biometric login off if it was set up for this account.
	static func forget(accountID: String) {
		if UserDefaults.standard.string(forKey: rememberedAccountKey) == accountID {
			disable()
		}
	}

	/// Shows the Face ID / Touch ID prompt and returns the remembered account if it succeeds.
	static func authenticate() async -> Outcome {
		let service = service
		let account = account
		let (data, status) = await Task.detached {
			let context = LAContext()
			context.localizedReason = "Log in to Wine Tracker"
			return Keychain.read(service: service, account: account, context: context)
		}.value

		switch status {
		case errSecSuccess:
			guard let data, let accountID = String(data: data, encoding: .utf8) else {
				disable()
				return .unavailable
			}
			return .success(accountID: accountID)
		case errSecItemNotFound:
			disable()
			return .unavailable
		default:
			return .cancelled
		}
	}

	private static var currentBiometryType: LABiometryType {
		let context = LAContext()
		_ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
		return context.biometryType
	}
}
