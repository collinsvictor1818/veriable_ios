import Foundation
import Security

/// A protocol defining secure storage operations.
protocol SecureStorageProtocol {
    func save(data: Data, service: String, account: String) throws
    func read(service: String, account: String) throws -> Data?
    func delete(service: String, account: String) throws
}

/// A wrapper around the Keychain for storing sensitive information securely.
final class SecureStorage: SecureStorageProtocol {
    func save(data: Data, service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AppError.data(.encodingFailed(NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)))
        }
    }
    
    func read(service: String, account: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw AppError.data(.decodingFailed(NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)))
        }
        
        return item as? Data
    }
    
    func delete(service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppError.data(.decodingFailed(NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)))
        }
    }
}

#if DEBUG
final class MockSecureStorage: SecureStorageProtocol {
    private var storage: [String: Data] = [:]
    
    func save(data: Data, service: String, account: String) throws {
        storage["\(service)-\(account)"] = data
    }
    
    func read(service: String, account: String) throws -> Data? {
        storage["\(service)-\(account)"]
    }
    
    func delete(service: String, account: String) throws {
        storage.removeValue(forKey: "\(service)-\(account)")
    }
}
#endif
