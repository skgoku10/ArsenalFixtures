import Foundation

struct MatchesResponse: Decodable {
    let matches: [Fixture]
}

struct Fixture: Decodable, Identifiable {
    let id: Int
    let utcDate: String
    let status: String
    let competition: Competition
    let homeTeam: Team
    let awayTeam: Team
    let score: Score
    /// Only populated when fetched from the single-match detail endpoint, not the list endpoint.
    let goals: [Goal]?

    var kickoff: Date? {
        ISO8601DateFormatter().date(from: utcDate)
    }

    var isLive: Bool {
        ["IN_PLAY", "PAUSED"].contains(status)
    }

    var isHome: Bool {
        homeTeam.id == FootballDataClient.arsenalTeamID
    }

    var opponent: Team {
        isHome ? awayTeam : homeTeam
    }

    var scoreText: String {
        guard let home = score.fullTime.home, let away = score.fullTime.away else { return "vs" }
        return "\(home) - \(away)"
    }
}

struct Competition: Decodable {
    let id: Int
    let name: String
}

struct Team: Decodable {
    let id: Int
    let name: String
    let shortName: String?
}

struct Score: Decodable {
    let fullTime: ScoreLine
}

struct ScoreLine: Decodable {
    let home: Int?
    let away: Int?
}
