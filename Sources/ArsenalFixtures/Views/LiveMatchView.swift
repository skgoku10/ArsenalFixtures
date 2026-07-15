import SwiftUI

struct LiveMatchView: View {
    let fixture: Fixture
    let scorers: [Goal]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.arsenalRed)
                    .frame(width: 6, height: 6)
                Text(statusLabel)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.arsenalRed)
                Spacer()
                Text(fixture.competition.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.arsenalGold)
            }

            HStack {
                Text(fixture.homeTeam.shortName ?? fixture.homeTeam.name)
                    .font(.system(size: 13, weight: fixture.isHome ? .bold : .regular))
                Spacer()
                Text(fixture.scoreText)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Spacer()
                Text(fixture.awayTeam.shortName ?? fixture.awayTeam.name)
                    .font(.system(size: 13, weight: fixture.isHome ? .regular : .bold))
            }

            if !scorers.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(scorers) { goal in
                        Text(goal.summary)
                            .font(.system(size: 11))
                    }
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.arsenalRed.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.arsenalGold.opacity(0.4), lineWidth: 1))
    }

    private var statusLabel: String {
        fixture.status == "PAUSED" ? "HALF-TIME" : "LIVE"
    }
}
