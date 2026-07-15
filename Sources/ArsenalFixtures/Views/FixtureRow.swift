import SwiftUI

struct FixtureRow: View {
    let fixture: Fixture

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM, HH:mm"
        return formatter
    }()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(fixture.isHome ? "Arsenal vs \(fixture.opponent.name)" : "\(fixture.opponent.name) vs Arsenal")")
                    .font(.system(size: 12, weight: .medium))
                Text(fixture.competition.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.arsenalGold)
            }
            Spacer()
            if let date = fixture.kickoff {
                Text(Self.dateFormatter.string(from: date))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
