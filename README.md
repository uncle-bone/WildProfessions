
## 1.2.0-test.2 full test build

This build adds a visible minimap button, a larger WildProfessions button on the open profession window, main-window controls for tracker/route arrow/map routes/diagnostics, and a guide index that includes every bundled profession guide even before the profession is scanned. No AH or auction pricing features are included. Gathering waypoints are approximate guide areas, not live node locations; the current map overlay displays steps that have map coordinates.

Install the `WildProfessions` folder into `Interface/AddOns`, then use the minimap icon or the visible `WildProfessions` profession-window button. The dashboard is the primary navigation surface; `/wp` remains an optional shortcut.

# WildProfessions

A standalone profession progress tracker and source-linked guide browser for WoW Forever.

**Current build:** 1.1.0-alpha.2 guide expansion (local preview; not yet released)  
**Client target:** WoW Forever 1.60.1, interface 16001, Lua 5.1

## Guide coverage

The addon bundles route summaries for Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring, Herbalism, Mining, Skinning, First Aid, Cooking, Fishing, and a combined Fishing + Cooking route. Each route links to its source guide and carries a confidence note for incomplete or beta-derived sections.

Use `/wp route` to print the selected profession's route, including the current skill bracket, alternatives and guide caveats. The dashboard and movable tracker continue to follow the character's live profession skill. When Fishing is selected, `/wp route` shows the combined Fishing + Cooking sequence and both current skill values.

The WoW-Professions Forever pages say their data is based on the Forever beta and some high skill ranges may not be live-tested. Several pages explicitly leave upper ranges or material lists incomplete. WildProfessions marks these gaps and does not invent recipes or present estimates as verified. The route records are original summaries, not copies of the site's page prose or map artwork.

This is guide coverage, not yet a full CraftRoute-style recipe planner. Recipe-by-recipe material accounting, shopping lists, Auctionator prices, automatic crafting, and verified waypoint pins remain future work. Gathering routes use broad zones and the game's built-in tracking; they do not show exact node spawns.

## Install

Extract the `WildProfessions` folder into the Forever client's `Interface/AddOns` directory. Enable it at character select and reload the UI.

## Commands

- `/wp` — open or close the dashboard
- `/wp route` — print the selected profession's full bundled route
- `/wp tracker` — show or hide the movable tracker
- `/wp guide` — show or hide the waypoint arrow
- `/wp refresh` — rescan profession skill
- `/wp lock` — lock or unlock the tracker
- `/wp diagnostics` — show client and route coverage

## Sources

The route index is [WoW-Professions Forever](https://www.wow-professions.com/forever). Individual route records link directly to each page. Guide content is beta-derived and should be checked against the live client, especially where a route or shopping list is labelled unfinished.

Route data credit: Loch Modan Herbalism waypoint sequence adapted from the user-provided ZygorProfessionsAllianceCLASSIC.lua file.
