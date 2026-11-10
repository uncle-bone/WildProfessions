# WildFarming RXP Route Pack

RestedXP-format Forever guides generated from the mapped route records bundled with WildProfessions. The pack includes 307 mapped material routes in 16 profession/faction guides.

## Install in WoW Forever

Copy the `WildFarmingRXP` folder into `Interface/AddOns` beside `RXPGuides`, then reload. Open RestedXP's guide selector and choose a guide under **WildFarming Routes**.

## Open in LevelForge Studio

Open https://levelforge.dev/studio and drop in `Routes.lua`. LevelForge Studio accepts RestedXP addon `.lua` guide files, so you can inspect, edit, and export the imported guides there.

## Guide behavior and limits

Each resource/zone entry is a RestedXP loop step with the route's map ID and ordered coordinates. Waypoints guide travel through suggested farming areas; RXP cannot confirm that a live resource node spawned at a waypoint. Steps are manually advanced with the RXP guide controls when you want to switch material or zone. Only rows with mapped coordinates are exported; zone-only recommendations stay in WildFarming's route browser.
