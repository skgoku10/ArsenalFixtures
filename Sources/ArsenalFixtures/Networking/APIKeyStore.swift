import Foundation

/// Stores the API-Football key in UserDefaults rather than the Keychain.
///
/// This app is built and run as an unsigned local binary (no stable code-signing
/// identity), and each rebuild gets a new ad-hoc signature. macOS Keychain ACLs
/// are tied to that signature, so a Keychain item written by one build silently
/// fails to read back after a rebuild/relaunch under a different signature.
/// UserDefaults has no such identity dependency, so it survives rebuilds.
enum APIKeyStore {
    private static let defaultsKey = "apiFootballKey"

    static func save(_ value: String) {
        UserDefaults.standard.set(value, forKey: defaultsKey)
    }

    static func load() -> String? {
        UserDefaults.standard.string(forKey: defaultsKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
}
