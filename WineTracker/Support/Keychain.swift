import Foundation
import LocalAuthentication
import Security

/// Thin wrapper over the Keychain's generic-password items.
nonisolated enum Keychain {

	/// Adds or replaces an item. Without `accessControl` it's readable whenever the device is unlocked.
	@discardableResult
	static func set(_ data: Data, service: String, account: String, accessControl: SecAccessControl? = nil) -> Bool {
		delete(service: service, account: account)
		var query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
			kSecValueData as String: data,
		]
		if let accessControl {
			query[kSecAttrAccessControl as String] = accessControl
		} else {
			query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
		}
		return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
	}

	/// Reading an item protected by biometrics shows the Face ID prompt and blocks until it's answered,
	/// so call this off the main thread.
	static func read(service: String, account: String, context: LAContext? = nil) -> (data: Data?, status: OSStatus) {
		var query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne,
		]
		if let context {
			query[kSecUseAuthenticationContext as String] = context
		}
		var result: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &result)
		return (result as? Data, status)
	}

	static func delete(service: String, account: String) {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
		]
		SecItemDelete(query as CFDictionary)
	}
}
