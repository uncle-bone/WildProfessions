# WildFarming

A standalone farming and gathering route addon for WoW Forever. It reuses the route and guide datasets bundled with WildProfessions, but does not require WildProfessions or SkillUp to be installed.

## Install

1. Download the repository branch ZIP: https://github.com/uncle-bone/WildProfessions/archive/refs/heads/ui/wildspark-style-dev9.zip
2. Extract the `WildFarming` folder from the archive into `World of Warcraft/_classic_/Interface/AddOns/`.
3. Confirm the folder contains `WildFarming.toc` directly, then restart or `/reload`.

## Use

- `/wfarm` opens the route planner.
- Choose a profession filter, search by resource or zone, and select a route to inspect it.
- Turn on character matching to filter routes by faction, character level, and known profession skill.
- Select **Track This Route** to open the map with the route path and numbered waypoints.
- The floating tracker follows the next waypoint and advances when you reach it. **Next Point** advances manually.
- `/wfarm next` advances the active route; `/wfarm stop` stops tracking.

## Route data

The addon includes the existing WildProfessions guide and gathering route datasets, including herb, ore, skinning, fishing, cooking, and other farming entries. Imported waypoint lines are route suggestions; they do not guarantee current live node spawns. Some guide zones have no mapped waypoints and are shown as zone-only entries.

## Build

Version: 0.1.0-dev. Installable source is in this folder. The addon is independent at runtime; the duplicated datasets are kept in sync with WildProfessions.
