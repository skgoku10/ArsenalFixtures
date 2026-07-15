import Foundation

struct Goal: Decodable, Identifiable {
    let minute: Int
    let injuryTime: Int?
    let type: String
    let team: GoalTeam
    let scorer: Player
    let assist: Player?

    var id: String {
        "\(minute)-\(injuryTime ?? 0)-\(scorer.id ?? 0)-\(type)"
    }

    var isOwnGoal: Bool { type == "OWN" }
    var isPenalty: Bool { type == "PENALTY" }

    var minuteText: String {
        if let injuryTime, injuryTime > 0 {
            return "\(minute)+\(injuryTime)'"
        }
        return "\(minute)'"
    }

    var summary: String {
        var text = "\(minuteText) \u{26BD} \(scorer.name ?? "Unknown")"
        if isOwnGoal {
            text += " (OG)"
        } else if isPenalty {
            text += " (pen)"
        }
        if let assistName = assist?.name {
            text += " (assist: \(assistName))"
        }
        return text
    }
}

struct GoalTeam: Decodable {
    let id: Int?
    let name: String?
}

struct Player: Decodable {
    let id: Int?
    let name: String?
}
