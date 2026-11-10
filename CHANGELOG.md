# Changelog

## 1.3.0-test.9-dev
- Rebuilt the addon landing screen as a profession dashboard with live-skill guide cards and direct navigation to the major features.
- Kept the farming atlas in its own page and improved the shared scroll sizing and clamping used by guide, atlas, shopping, and report lists.
- Reworked the live tracker and utility windows to use the WildProfessions frame style.
- Replaced imported source filenames in player-facing route metadata with neutral route labels.
- Removed third-party source names from player-facing route and diagnostic text.

## 1.3.0-test.8-dev
- Added a large imported farm-route catalog with faction and skill metadata. Entries without coordinates remain text-only.
- Added an all-farms view with category-aware search and waypoint counts.
- Loaded route data as a standalone addon data file.

## 1.3.0-test.7-dev
- Added a separate Farming & Gathering Atlas with profession filters and zone/material search.
- Listed mapped farm records by zone, material, skill threshold, faction, and waypoint count.
- Reflowed guide-card columns and improved scrolling in guide, shopping, and report views.

## 1.3.0-test.6-dev
- Held the combined Fishing + Cooking route out of guide selection and runtime tracking; standalone Cooking and Fishing remain available.
- Expanded standalone Cooking into skill sections with recipe alternatives, unlock gates, estimated quantities, and carry-forward notes.
- Expanded Camping and Merchant's Favor references with mechanics and live-verification notes.
- Disabled Auction House pricing and search integrations.

## 1.3.0-test.4
- Restored the missing vendor-only item value function so the planner pricing file loads.
- Guarded tracker settings during early frame callbacks before saved variables are ready.

## 1.3.0-test.3
- Integrated the profession planner and profession-pane interface into WildProfessions.
- Rebranded planner title, saved variables, reports, settings, and slash dispatch.
- Unified `/wp` and `/wildprofessions` commands.
- Removed Auction House pricing, search, collection, and shopping-list integrations.
- Included the planner engine's GPL-3.0-or-later license and third-party notices.
