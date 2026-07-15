import Foundation

/// Small UserDefaults-backed settings store shared between the settings UI and the poller.
/// The API key itself is also stored via UserDefaults, in APIKeyStore.
enum Settings {
    private static let defaults = UserDefaults.standard

    private enum Key {
        static let liveRefreshInterval = "liveRefreshInterval"
        static let idleRefreshInterval = "idleRefreshInterval"
        static let upcomingCount = "upcomingCount"
    }

    /// How often (seconds) to poll while an Arsenal match is live. football-data.org's free
    /// tier allows 10 requests/minute with no daily cap, so this can be fairly aggressive.
    static var liveRefreshInterval: TimeInterval {
        get {
            let value = defaults.double(forKey: Key.liveRefreshInterval)
            return value > 0 ? value : 60
        }
        set { defaults.set(newValue, forKey: Key.liveRefreshInterval) }
    }

    /// How often (seconds) to poll for an upcoming kickoff / refresh the fixtures list
    /// when nothing is live.
    static var idleRefreshInterval: TimeInterval {
        get {
            let value = defaults.double(forKey: Key.idleRefreshInterval)
            return value > 0 ? value : 2 * 60 * 60
        }
        set { defaults.set(newValue, forKey: Key.idleRefreshInterval) }
    }

    static var upcomingCount: Int {
        get {
            let value = defaults.integer(forKey: Key.upcomingCount)
            return value > 0 ? value : 8
        }
        set { defaults.set(newValue, forKey: Key.upcomingCount) }
    }
}
