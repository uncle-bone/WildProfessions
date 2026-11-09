## 1.2.0-test.6
- Added 163 faction-aware farming paths from the supplied Zygor profession guides across Herbalism, Mining, Skinning, and Fishing, including the material farming guides.
- Reworked the map overlay to draw each route separately, deduplicate shared paths, color routes by profession, and show route names and skill requirements on hover.
- Refreshes route geometry only when the map or selected profession changes to avoid rebuilding overlay frames every update tick.
- Added the full route dataset as a separate load-once Lua data file and credited the supplied Alliance/Horde guide files.

## 1.2.0-test.5
- Added Fishing leveling map routes, starter and faction water stops, the Nat Pagle quest fish locations, and item-specific fish farming pins adapted from the supplied Zygor profession guide.
- Added fishing farming pins to the map overlay and made alternate route selection prefer the zone currently shown on the world map.
- Updated attribution for the adapted Fishing location data.

## 1.2.0-test.4
- Replaced cramped dashboard with a searchable guide library, clearer route card, skill progress, and large in-window controls.
- Styled the tracker and actions with a dark, high-contrast green accent theme.

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
