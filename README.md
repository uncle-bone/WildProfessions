# WildProfessions

WildProfessions is a standalone World of Warcraft Forever profession guide and planning addon. The interface is organized around a home dashboard, profession guides, a separate farming atlas, material notes, and a live tracker.

**Build:** 1.3.0-test.9-dev  
**Client:** Forever 1.60.1 / interface 16001  
**Open:** minimap icon, AddOn Compartment, or `/wp`  
**Download:** [WildProfessions 1.3.0-test.9-dev](https://github.com/uncle-bone/WildProfessions/raw/refs/heads/main/downloads/WildProfessions-1.3.0-test.9-dev.zip)

**Standalone farming + RXP profession guides (dev 0.2.0):** [Download current GitHub branch ZIP](https://github.com/uncle-bone/WildProfessions/archive/refs/heads/ui/wildspark-style-dev9.zip). Copy `WildProfessions/WildFarming` and/or `WildProfessions/WildFarmingRXP` into `Interface/AddOns` beside `RXPGuides`. The RXP pack includes 1–300 skill-gated guides for gathering and crafting professions; its `Routes.lua` can also be opened in [LevelForge Studio](https://levelforge.dev/studio).

## Interface

- **Home** shows detected skills, guide cards, and quick links to the main tools.
- **Guides** resumes each profession at its current skill and exposes recipe steps, materials, route choices, and progress controls.
- **Farming** is a separate searchable atlas for Herbalism, Mining, Skinning, Fishing, and all farm records. Routes with coordinates open their map; text-only recommendations are clearly marked.
- **Materials** opens the current guide's shopping notes. **More** contains Camping and Merchant's Favor references.
- A movable tracker, minimap icon, route arrow, and map overlay are available from the addon interface.

No companion addons are required. Auction House features are disabled; bag counts and vendor information remain available.

Route coverage varies. Some guide choices have no mapped coordinates, and imported route points may need confirmation in the Forever client.

## Commands

- `/wp` opens the home dashboard.
- `/wp tracker` toggles the progress tracker.
- `/wp guide` toggles the route arrow.
- `/wp route` prints the selected guide steps.
- `/wp shopping` opens material notes.
- `/wp refresh` rescans professions and guide progress.

## Credits and license

The embedded planner engine is based on SkillUp Forever by Cillian Berragan under GPL-3.0-or-later. Its license and third-party notices are included with the addon.
