# WildProfessions

A standalone profession tracker and guide addon for WoW Forever.

**Current build:** 1.1.0-alpha.1 preview  
**Client target:** WoW Forever 1.60.1, interface 16001, Lua 5.1

## What works in this preview

- Reads the character's current profession skill and cap from the game APIs.
- Automatically selects the next Herbalism step from the live skill value; the guide catches up when a character starts partway through.
- Reminds you to train Journeyman, Expert, or Artisan when your skill cap shows that rank is missing.
- Shows a movable step tracker and a separate movable directional arrow to the current route waypoint.
- Provides a Skyborne-friendly starter waypoint and an Alliance Herbalism progression through 300.
- Uses the game's Find Herbs tracking for actual herb nodes. The addon arrow points to an approximate farming area; it does not track individual herb spawns.
- Keeps the addon standalone; Questie, QuestieDB, Zygor, and RestedXP are not runtime requirements.

## Current guide coverage

Herbalism is the first bundled route. The other professions from the WoW Professions Forever index are not in the addon yet. The route has concise original instructions based on the guide's skill brackets and herb requirements. Farming waypoints are area-level approximations, and the source notes its 170+ route was not fully live-tested.

Recipe crafting lists, shopping totals, auction prices, recipe availability tracking, and trainer route automation are not included in this preview.

## Install

Download the repository ZIP, extract it, then copy the inner `WildProfessions` folder into the Forever client's `Interface/AddOns` directory. Enable WildProfessions at character select and reload the UI.

## Commands

- `/wp` — open or close the dashboard
- `/wp tracker` — show or hide the movable profession step tracker
- `/wp guide` — show or hide the waypoint arrow
- `/wp refresh` — rescan the live profession skill
- `/wp lock` — lock or unlock the tracker
- `/wp diagnostics` — show detected client and guide coverage

## Source

The route is an original in-addon summary of the public [WoW Forever Herbalism guide](https://www.wow-professions.com/forever/herbalism-leveling-guide). It does not include that page's prose or map artwork.
