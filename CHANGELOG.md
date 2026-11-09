## 1.2.0-test.3
- Fixed route arrow player-coordinate handling so it computes direction instead of silently losing the Y coordinate.

## 1.2.0-test.2
- Fixed map overlay rendering on the Forever world map and removed unsupported map event registration.
- Added the Zygor-derived Loch Modan Herbalism route and route line markers.
- Route arrow follows the nearest route waypoint and opens the selected guide map.
- Included attribution for the adapted route data.

## 1.2.0-test.1
- Added minimap launcher and visible profession-window launcher.
- Added dashboard controls for tracker, route arrow, map routes, and diagnostics.
- Exposed all bundled profession guides in the dashboard before profession scanning.
- Added World Map route marker overlay for route steps with coordinates.
- Kept the addon standalone with no auction house features or added dependencies.

# Changelog

## 1.1.0-alpha.2 - Source-linked guide expansion

- Added original source-linked route summaries for all 13 profession guide entries, including the combined Fishing + Cooking route.
- Added `/wp route` to show all bundled skill steps, alternatives and source confidence notes.
- Generalized rank reminders and tracker completion text for professions beyond Herbalism.
- Expanded Herbalism route choices and documented Mining, Skinning and other gathering zone brackets.
- Marked incomplete and beta-derived guide ranges instead of filling gaps with unverified recipes.
- Updated README to state what this guide expansion does and what a full recipe planner still needs.

This is an unpublished local preview. It has not been tested in the Forever client. CraftRoute code was not copied; its repository did not specify reuse terms. No exact recipe-by-recipe shopping engine is included in this build.

## 1.1.0-alpha.1 - Skill-tracked Herbalism guide

- Added a guide runtime that chooses steps from the live profession skill and current rank cap.
- Added Herbalism rank-training reminders at skill 50, 125, and 200.
- Added a movable route tracker and directional waypoint arrow.
- Added a Skyborne starter step and Alliance-friendly Herbalism route through skill 300.
- Marked route-area waypoint coordinates as approximate and retained the source's high-level validation caveat.
- Kept the addon independent of external guide or database addons.
