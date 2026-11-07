# WildProfessions source and compatibility notes

Research date: 2026-11-07. Target reported by maintainer: WoW Forever 1.60.1.70790.

The current `forever` UI-source mirror reports 1.60.1.70862. Its interface/API documentation is useful for API shape, but runtime behavior on the last reported 70790 client still needs an in-game check.

## Source facts

- The public Wowhead Forever profession overview is labeled Patch 1.60.1, reports 600+ added recipes, and presents profession-specific recipe lists and sources: https://www.wowhead.com/forever/guide/professions/overview
- Wowhead describes the Classic framework of two primary professions, all three secondary professions, a 300 skill cap, plus a dedicated profession window and Forever additions: https://www.wowhead.com/forever/guide/wow-forever-profession-pairings-by-class-35082
- WoW-Professions.com offers Forever leveling guides, but states the guides are based on beta and that upper levels may not have been tested on live: https://www.wow-professions.com/forever
- The upstream NaowhForever profession module references `GetProfessions`, `GetProfessionInfo`, `C_TradeSkillUI`, `C_Item`, `C_Container`, and auction APIs. Presence in that source does not prove availability or behavior in the installed Forever client.
- The uploaded NaowhForever source is governed by an all-rights-reserved license except for separately licensed components. This addon does not copy its source, data, or artwork.

## Implementation status

- Profession detection: guarded legacy `GetProfessions`/`GetProfessionInfo`; optional guarded `C_TradeSkillUI` fallback. Must be confirmed on the live client.
- Recipe scanning: not implemented because the target build's profession API surface is not yet verified.
- Recipe and route database: not bundled. Wowhead and WoW-Professions can inform later source-attributed records; guide recommendations are not live-verified by this addon.
- Prices, skill-up chance, gathering coordinates, Legacy, Camping, Merchant's Favor: not implemented.

## Verification boundary

Static checks can validate Lua syntax, TOC ordering, and ZIP layout. They cannot establish Forever API compatibility, runtime safety, visual behavior, or recipe correctness. A live client test is required.

