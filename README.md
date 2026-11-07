# WildProfessions

Independent profession progress tracker for World of Warcraft: Forever.

**Current build:** 1.0.0 testing foundation (not yet a feature-complete release)  
**Target client:** WoW Forever; last reported build 1.60.1.70790. Interface compatibility must be confirmed in game.

## Current implementation

- Detects profession skill snapshots through the legacy profession API when available, with a guarded newer-API fallback.
- Tracks per-character profession skill and bounded skill-change history in SavedVariables.
- Provides a movable dashboard and compact tracker, display selection, hide/lock controls, and diagnostics.
- Keeps three planning strategy preferences (fastest, cheapest, materials already owned).
- Explicitly reports when route data is unavailable instead of inventing recipe, price, or skill-up recommendations.
- Has no external addon dependency and performs scans only on login or profession-related events/manual refresh.
- Adds a small `WP` launcher beside the active profession window and opens an addon-owned planner companion beside it. Use `/wp` for the standalone view.
- Detects the NaowhForever profession window when it is active and follows that window instead of the transparent native frame.
- Remains independent of EllesmereUI; its launcher and panel are separate frames and never move, resize, reparent, scale, or add children to Blizzard's profession frame.

## Not implemented in this foundation

Recipe enumeration, researched 1-300 routes, material inventory matching, shopping/crafting queue UI, trainer maps, auction prices, gathering routes, Legacy/Camping/Merchant's Favor datasets, and live-client verification are not yet complete. These must be added from compatible APIs and source-attributed Forever data before calling the addon feature-complete.

## Profession-window integration and UI compatibility

The addon uses the Forever profession window's open/close and profession-selection signals to keep its panel contextual. The `WP` launcher and planner are top-level addon frames. They anchor to the active profession window as siblings; they do not replace its recipe list or change its protected frame. If NaowhForever's `NaowhForeverProfessions` window is visible, WildProfessions uses that as the host. Otherwise it uses the visible native `ProfessionsFrame`. EllesmereUI remains optional and is not queried for theme internals or required as a dependency. See [compatibility notes](docs/COMPATIBILITY.md).

## Install

Copy the `WildProfessions` folder into `World of Warcraft/_retail_/Interface/AddOns/` (use the AddOns directory for your Forever client), then enable it on the character select screen. Use `/wp` to open the dashboard.

## Commands

- `/wp` - show/hide dashboard
- `/wp refresh` - refresh profession snapshot
- `/wp tracker` - show/hide compact tracker
- `/wp lock` - toggle tracker movement lock
- `/wp diagnostics` - report build and API detection status

## Research and licensing

The independent design uses NaowhForever only as architectural research; no NaowhForever source, databases, or artwork are included. Profession recipes and leveling routes need their own provenance and live verification. See [research notes](docs/RESEARCH.md).

