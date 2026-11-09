## 1.3.0-test.8-dev — Farming Atlas build

[Download WildProfessions 1.3.0-test.8-dev](https://github.com/uncle-bone/WildProfessions/raw/refs/heads/main/downloads/WildProfessions-1.3.0-test.8-dev.zip)

The separate Farming Guides atlas now includes 345 source records imported from the supplied Zygor Alliance/Horde profession guide files: 307 entries have source waypoint coordinates and 38 are listed as text-only because those guides contain no usable coordinates. The All Farms view searches across the categories; Herbalism, Mining, Skinning, and Fishing filters remain. Route overlays draw only routes with coordinates. Static package validation passed; this is a test build, not a stable release.

Install by extracting the `WildProfessions` folder into `Interface/AddOns`.

## Previous build: 1.3.0-test.3

[Download WildProfessions 1.3.0-test.3](https://github.com/uncle-bone/WildProfessions/raw/refs/heads/main/downloads/WildProfessions-1.3.0-test.3.zip)

This is an install-ready test ZIP. It is superseded by test.4.

## Previous build: 1.2.0-test.6 full test build

This build adds 163 faction-aware farming paths adapted from the supplied Zygor profession files for Herbalism, Mining, Skinning, and Fishing, including the item farming guides and Alliance/Horde locations. Map routes draw independently, avoid connecting separate farming loops, and show the route/item name and skill requirement when you hover a pin. Existing launcher, dashboard, tracker, arrow, and profession guides remain included. No AH or auction pricing features are included. Gathering paths are guide routes, not live node spawns; fishing pins mark water access or school areas, not guaranteed active pools.

Install the `WildProfessions` folder into `Interface/AddOns`, then use the minimap icon or the visible `WildProfessions` profession-window button. The dashboard is the primary navigation surface; `/wp` remains an optional shortcut.

# WildProfessions

A standalone profession progress tracker and source-linked guide browser for WoW Forever.

**Current build:** 1.3.0-test.3 (test build; not a stable release)  
**Client target:** WoW Forever 1.60.1, interface 16001, Lua 5.1

## Guide coverage

The addon bundles route summaries for Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring, Herbalism, Mining, Skinning, First Aid, Cooking, and Fishing. The combined Fishing + Cooking guide remains paused. Each route links to its source guide and carries a confidence note for incomplete or beta-derived sections.

Use `/wp route` to print the selected profession's route, including the current skill bracket, alternatives and guide caveats. The dashboard and movable tracker continue to follow the character's live profession skill. Standalone Fishing and Cooking progress are tracked independently. The combined Fishing + Cooking route remains on hold until its step synchronization is fixed.

The WoW-Professions Forever pages say their data is based on the Forever beta and some high skill ranges may not be live-tested. Several pages explicitly leave upper ranges or material lists incomplete. WildProfessions marks these gaps and does not invent recipes or present estimates as verified. The route records are original summaries, not copies of the site's page prose or map artwork.

This is guide coverage, not yet a full CraftRoute-style recipe planner. Recipe-by-recipe material accounting, shopping lists, Auctionator prices, and automatic crafting remain future work. Map routes use the supplied guide coordinates; they do not identify live node spawns.

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

Route data credit: Loch Modan Herbalism route and gathering/farming waypoints adapted from the user-provided ZygorProfessionsAllianceCLASSIC.lua and ZygorProfessionsHordeCLASSIC.lua files. WildProfessions' route renderer and guide integration are original; all coordinates should be checked in the Forever client.


