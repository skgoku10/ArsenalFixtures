# Arsenal Fixtures

A native macOS menu bar app showing Arsenal's fixtures, live scores, and live
goal scorers — no Dock icon, lives entirely in the menu bar.

Built with SwiftUI's `MenuBarExtra` (macOS 13+) as a Swift Package, using the
[football-data.org](https://www.football-data.org/) v4 API.

## Features

- Upcoming fixtures (competitions covered by your plan — see below)
- Live match card with running score, that updates while a match is in play
- Live **goal scorers** (and assists, own goals, penalties) as they happen
- Menu bar title shows the live score during a match, "ARS" otherwise
- API key stored locally via UserDefaults
- Configurable refresh intervals

## Setup

1. **Get a free API key** at https://www.football-data.org/client/register
   (free tier: 10 requests/minute, no daily cap).
2. **Run the app** (two options below), open its menu bar icon, click
   **Settings…**, paste in your key, and click **Save**.

### Option A — Run from Xcode (for development)

Open the `ArsenalFixtures` folder in Xcode (`File > Open…`, select the folder
containing `Package.swift`), select the `ArsenalFixtures` scheme, and hit Run.

### Option B — Build a real .app bundle (for daily use)

```bash
./Scripts/build_app.sh
cp -r ArsenalFixtures.app /Applications/
```

Then launch **Arsenal Fixtures** from Launchpad/Spotlight like any other app.
To have it start automatically at login, add it in
**System Settings > General > Login Items**.

## Notes on the free API tier

football-data.org's free tier is generous on rate limit (10 requests/minute,
no daily cap), but restricts *competition* coverage: the "TIER_ONE" free set
includes the Premier League and UEFA club competitions (Champions League,
Europa League), but domestic cups (FA Cup, League Cup) may not be included.
So "upcoming fixtures" in practice means whatever competitions your plan
covers, not strictly every competition Arsenal play in — if fixtures look
sparse, that's the likely reason. Live and idle refresh intervals are
adjustable in Settings if you want to tune request usage further.

## Project layout

```
Sources/ArsenalFixtures/
  ArsenalFixturesApp.swift      # @main, MenuBarExtra scene
  Models/                       # Fixture / Goal JSON models
  Networking/                   # API client, key storage, settings
  ViewModel/                    # Polling + state
  Views/                        # Menu bar dropdown UI
Scripts/build_app.sh            # Packages a release build into a .app bundle
```
