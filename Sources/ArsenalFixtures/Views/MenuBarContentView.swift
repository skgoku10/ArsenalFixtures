import SwiftUI
import AppKit

struct MenuBarContentView: View {
    @ObservedObject var viewModel: FixturesViewModel
    @Environment(\.openWindow) private var openWindow

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            if !viewModel.hasAPIKey {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if let live = viewModel.liveFixture {
                            LiveMatchView(fixture: live, scorers: viewModel.goalScorers)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 11))
                                .foregroundStyle(.orange)
                        }

                        Text("UPCOMING \u{2022} ALL COMPETITIONS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.arsenalGold)

                        if viewModel.upcomingFixtures.isEmpty {
                            Text(viewModel.isLoading ? "Loading\u{2026}" : "No upcoming fixtures found.")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.upcomingFixtures) { fixture in
                                FixtureRow(fixture: fixture)
                            }
                        }
                    }
                }
                .frame(maxHeight: 320)
            }

            Divider()
            footer
        }
        .padding(12)
        .frame(width: 300)
        .onAppear { viewModel.start() }
    }

    private func openSettings() {
        openWindow(id: "settings")
        NSApp.activate(ignoringOtherApps: true)
    }

    private var header: some View {
        HStack {
            Text("Arsenal Fixtures")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.arsenalRed)
            Spacer()
            Button {
                viewModel.refreshNow()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.arsenalGold)
            .disabled(viewModel.isLoading)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Add your football-data.org key to get started.")
                .font(.system(size: 12))
            Button("Open Settings") { openSettings() }
        }
    }

    private var footer: some View {
        HStack {
            if let lastUpdated = viewModel.lastUpdated {
                Text("Updated \(Self.timeFormatter.string(from: lastUpdated))")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Settings\u{2026}") { openSettings() }
                .buttonStyle(.plain)
                .font(.system(size: 11))
            Button("Quit") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.plain)
                .font(.system(size: 11))
        }
    }
}
