import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: FixturesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = APIKeyStore.load() ?? ""
    @State private var liveInterval: Double = Settings.liveRefreshInterval
    @State private var idleIntervalHours: Double = Settings.idleRefreshInterval / 3600
    @State private var savedMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text("football-data.org key")
                    .font(.system(size: 12, weight: .medium))
                SecureField("Paste your football-data.org key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                Text("Get a free key at football-data.org/client/register. Free tier: 10 requests/minute, no daily cap, but competition coverage is limited (Premier League and UEFA competitions are covered; some domestic cups may not be).")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Live refresh interval: \(Int(liveInterval))s")
                    .font(.system(size: 12, weight: .medium))
                Slider(value: $liveInterval, in: 30...300, step: 15)
                Text("Each live poll costs up to 2 requests. The free tier allows 10/minute, so anything above 15s is comfortably safe.")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Idle refresh interval: \(String(format: "%.1f", idleIntervalHours))h")
                    .font(.system(size: 12, weight: .medium))
                Slider(value: $idleIntervalHours, in: 1...12, step: 0.5)
            }

            if let savedMessage {
                Text(savedMessage)
                    .font(.system(size: 11))
                    .foregroundStyle(.green)
            }

            HStack {
                Button("Clear Key") {
                    APIKeyStore.clear()
                    apiKey = ""
                }
                Spacer()
                Button("Save") {
                    APIKeyStore.save(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
                    Settings.liveRefreshInterval = liveInterval
                    Settings.idleRefreshInterval = idleIntervalHours * 3600
                    savedMessage = "Saved."
                    viewModel.refreshNow()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 340)
    }
}
