# WildFarming RXP Profession Guides

A RestedXP guide pack for WoW Forever with **16 skill-progressing 1–300 guides**:

- Gathering: Herbalism, Mining, Skinning, and Fishing, each with Alliance and Horde waypoint loops.
- Crafting: Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring, Cooking, and First Aid, with skill-bracket steps and suggested Forever recipes.

## Install in WoW Forever

1. Download the current WildProfessions branch ZIP linked from the repository README.
2. Remove the old `WildFarmingRXP` folder from `Interface/AddOns`.
3. Copy the new `WildProfessions/WildFarmingRXP` folder into `Interface/AddOns` beside `RXPGuides`.
4. Reload the game. In RXP, open the guide selector and choose a guide under **Profession Leveling**.

Each step is gated by the profession skill threshold. It should stay on the current bracket until your skill reaches that target. Crafting steps list recipes from the Forever skill threshold database; use the profession window to confirm a recipe is currently orange or yellow, then craft until the guide advances. Train new ranks at 50, 125, and 200; Cooking and First Aid may require books or quests for rank upgrades.

## Open in LevelForge Studio

Open https://levelforge.dev/studio and drop in `Routes.lua`. LevelForge Studio accepts RestedXP addon `.lua` guide files, so you can inspect, edit, and export these guides there.

## Data limits

Craft suggestions use the bundled Forever 1.60.1.70862 skill-threshold data. Recipe availability and skill colors in your Forever profession window take precedence. Gathering coordinates are imported route suggestions and are not guaranteed live node spawns. In-game validation of this corrected pack is still needed.
