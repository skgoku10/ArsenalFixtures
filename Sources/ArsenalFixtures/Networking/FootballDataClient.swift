import Foundation

enum FootballDataError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case http(Int)
    case api(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "No API key set. Add your football-data.org key in Settings."
        case .invalidResponse:
            return "Received an unexpected response from the API."
        case .http(let code):
            if code == 429 {
                return "API rate limit reached (10 requests/minute on the free tier). Try again shortly."
            }
            if code == 403 {
                return "Access denied \u{2014} this fixture's competition may not be covered by your plan."
            }
            return "API request failed (HTTP \(code))."
        case .api(let message):
            return message
        }
    }
}

private struct APIErrorMessage: Decodable {
    let message: String
}

final class FootballDataClient {
    /// Arsenal FC's team id in the football-data.org database.
    static let arsenalTeamID = 57

    private let baseURL = URL(string: "https://api.football-data.org/v4")!
    private let session = URLSession.shared

    private var apiKey: String? {
        APIKeyStore.load()
    }

    private func request(path: String, query: [String: String] = [:]) async throws -> Data {
        guard let apiKey, !apiKey.isEmpty else {
            throw FootballDataError.missingAPIKey
        }

        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        var request = URLRequest(url: components.url!)
        request.setValue(apiKey, forHTTPHeaderField: "X-Auth-Token")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw FootballDataError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            if let decoded = try? JSONDecoder().decode(APIErrorMessage.self, from: data) {
                throw FootballDataError.api(decoded.message)
            }
            throw FootballDataError.http(http.statusCode)
        }
        return data
    }

    /// Next N upcoming Arsenal fixtures, across whichever competitions the plan covers.
    /// "SCHEDULED" covers fixtures without a confirmed kickoff time yet; "TIMED" covers
    /// fixtures with one. Most near-term matches are TIMED, so both are needed.
    func upcomingFixtures(count: Int = 10) async throws -> [Fixture] {
        let data = try await request(
            path: "teams/\(Self.arsenalTeamID)/matches",
            query: ["status": "SCHEDULED,TIMED", "limit": String(count)]
        )
        let matches = try JSONDecoder().decode(MatchesResponse.self, from: data).matches
        return matches.sorted { ($0.kickoff ?? .distantFuture) < ($1.kickoff ?? .distantFuture) }
    }

    /// The Arsenal fixture currently in play, if any (score only, no goal detail).
    func liveFixture() async throws -> Fixture? {
        let data = try await request(
            path: "teams/\(Self.arsenalTeamID)/matches",
            query: ["status": "LIVE"]
        )
        return try JSONDecoder().decode(MatchesResponse.self, from: data).matches.first
    }

    /// Full detail for one match, including the goals array (scorers/assists).
    func matchDetail(id: Int) async throws -> Fixture {
        let data = try await request(path: "matches/\(id)")
        return try JSONDecoder().decode(Fixture.self, from: data)
    }
}
