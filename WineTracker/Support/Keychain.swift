import Foundation
import LocalAuthentication
import Security

/// Thin wrapper over the Keychain's generic-password items.
nonisolated enum Keychain {

	/// Adds or replaces an item. Without `accessControl` it's readable whenever the device is unlocked.
	/// Returns false if nothing was saved; an item it was replacing is then left as it was.
	@discardableResult
	static func set(_ data: Data, service: String, account: String, accessControl: SecAccessControl? = nil) -> Bool {
		let match: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: account,
		]
		var item = match
		item[kSecValueData as String] = data
		if let accessControl {
			// An item's access control can't be updated in place, so it's replaced. Only biometric
			// login uses this, and losing its item just turns that off.
			item[kSecAttrAccessControl as String] = accessControl
			delete(service: service, account: account)
			return SecItemAdd(item as CFDictionary, nil) == errSecSuccess
		}
		// Updating in place keeps the old data if the write fails, so a failed password change
		// leaves the current password working.
		let status = SecItemUpdate(match as CFDictionary, [kSecValueData as String: data] as CFDictionary)
		guard status == errSecItemNotFound else { return status == errSecSuccess }
		item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
		return SecItemAdd(item as CFDictionary, nil) == errSecSuccess
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
