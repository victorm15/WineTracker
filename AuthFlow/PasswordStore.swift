import Foundation
import CommonCrypto
import Security

/// Salted PBKDF2 password hashes, kept in the Keychain. The password itself is never saved.
/// Hashing is deliberately slow (around half a second), so it always runs off the main thread.
nonisolated enum PasswordStore {

	private struct Record: Codable {
		let salt: Data
		let hash: Data
		let iterations: Int
	}

	private static let service = "VictorM.wine-tracker.password"
	private static let iterations = 600_000
	private static let saltLength = 16
	private static let hashLength = 32

	static func save(_ password: String, for accountID: String) async -> Bool {
		await Task.detached {
			guard let salt = randomSalt(),
				  let hash = derive(password, salt: salt, iterations: iterations),
				  let data = try? JSONEncoder().encode(Record(salt: salt, hash: hash, iterations: iterations)) else {
				return false
			}
			return Keychain.set(data, service: service, account: accountID)
		}.value
	}

	/// Pass `nil` when no account matched the username: the hash still runs, so a wrong
	/// username takes as long as a wrong password and doesn't reveal which accounts exist.
	static func verify(_ password: String, for accountID: String?) async -> Bool {
		await Task.detached {
			guard let accountID,
				  let data = Keychain.read(service: service, account: accountID).data,
				  let record = try? JSONDecoder().decode(Record.self, from: data) else {
				_ = derive(password, salt: Data(count: saltLength), iterations: iterations)
				return false
			}
			guard let hash = derive(password, salt: record.salt, iterations: record.iterations) else { return false }
			return constantTimeEqual(hash, record.hash)
		}.value
	}

	static func delete(for accountID: String) {
		Keychain.delete(service: service, account: accountID)
	}

	private static func randomSalt() -> Data? {
		var salt = Data(count: saltLength)
		let status = salt.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, saltLength, $0.baseAddress!) }
		return status == errSecSuccess ? salt : nil
	}

	private static func derive(_ password: String, salt: Data, iterations: Int) -> Data? {
		let passwordBytes = Array(password.utf8)
		var derived = Data(count: hashLength)
		let status = derived.withUnsafeMutableBytes { derivedBuffer in
			salt.withUnsafeBytes { saltBuffer in
				passwordBytes.withUnsafeBufferPointer { passwordBuffer in
					passwordBuffer.withMemoryRebound(to: CChar.self) { passwordChars in
						CCKeyDerivationPBKDF(
							CCPBKDFAlgorithm(kCCPBKDF2),
							passwordChars.baseAddress, passwordChars.count,
							saltBuffer.bindMemory(to: UInt8.self).baseAddress, salt.count,
							CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
							UInt32(iterations),
							derivedBuffer.bindMemory(to: UInt8.self).baseAddress, hashLength
						)
					}
				}
			}
		}
		return status == kCCSuccess ? derived : nil
	}

	/// Compares every byte so the time taken doesn't hint at how much of the hash matched.
	private static func constantTimeEqual(_ a: Data, _ b: Data) -> Bool {
		guard a.count == b.count else { return false }
		var difference: UInt8 = 0
		for (x, y) in zip(a, b) {
			difference |= x ^ y
		}
		return difference == 0
	}
}
