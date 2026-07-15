import Foundation
import SwiftUI

@MainActor
final class FixturesViewModel: ObservableObject {
    @Published var upcomingFixtures: [Fixture] = []
    @Published var liveFixture: Fixture?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    private let client = FootballDataClient()
    private var pollTask: Task<Void, Never>?

    var goalScorers: [Goal] {
        liveFixture?.goals ?? []
    }

    var hasAPIKey: Bool {
        APIKeyStore.load()?.isEmpty == false
    }

    func start() {
        guard pollTask == nil else { return }
        pollTask = Task { [weak self] in
            await self?.pollLoop()
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
    }

    func refreshNow() {
        Task { await self.refreshCycle() }
    }

    private func pollLoop() async {
        while !Task.isCancelled {
            await refreshCycle()
            let interval = liveFixture != nil ? Settings.liveRefreshInterval : idleIntervalUntilNextKickoff()
            try? await Task.sleep(nanoseconds: UInt64(max(interval, 15)) * 1_000_000_000)
        }
    }

    /// If a fixture is due to kick off soon, poll more eagerly so we catch kickoff promptly;
    /// otherwise fall back to the long idle interval to conserve the daily request quota.
    private func idleIntervalUntilNextKickoff() -> TimeInterval {
        guard let next = upcomingFixtures.first?.kickoff else {
            return Settings.idleRefreshInterval
        }
        let secondsUntilKickoff = next.timeIntervalSinceNow
        if secondsUntilKickoff > 0 && secondsUntilKickoff < 15 * 60 {
            return Settings.liveRefreshInterval
        }
        return Settings.idleRefreshInterval
    }

    private func refreshCycle() async {
        guard hasAPIKey else {
            errorMessage = FootballDataError.missingAPIKey.localizedDescription
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if let live = try await client.liveFixture() {
                liveFixture = try await client.matchDetail(id: live.id)
            } else {
                liveFixture = nil
            }

            upcomingFixtures = try await client.upcomingFixtures(count: Settings.upcomingCount)
            errorMessage = nil
            lastUpdated = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
