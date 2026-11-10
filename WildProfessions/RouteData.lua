local _, WP = ...

WP.RouteData = {
    herbalism = {
        name = "Herbalism",
        maxSkill = 300,
        source = "Bundled profession guide",
        sourceStatus = "The source is beta-derived; portions above skill 170 may not be live-tested.",
        routeNote = "Waypoints mark approximate farming areas, not herb node locations. Use Find Herbs on the minimap for live node tracking.",
        rankGates = {
            { skill = 50, cap = 75, rank = "Journeyman" },
            { skill = 125, cap = 150, rank = "Expert" },
            { skill = 200, cap = 225, rank = "Artisan" },
        },
        trainer = {
            zone = "Zephras Isle",
            mapID = 2521,
            x = 57.9,
            y = 75.5,
            name = "Syriel Nightrain",
            note = "Skyborne trainers Syriel Nightrain and Halassa Fernbreeze can train Herbalism through 300. Alliance capital trainers are alternatives.",
        },
        steps = {
            {
                target = 50,
                title = "Starter herbs · 1–50",
                zone = "Zephras Isle",
                mapID = 2521,
                x = 46.9,
                y = 26.0,
                herbs = "Peacebloom · Silverleaf · Earthroot at skill 15",
                instructions = "Gather around the starter area until Herbalism reaches 50. Skyborne can learn Herbalism from the Harvesting Windstones quest reward or a trainer. Turn on Find Herbs; tracking turns off after death.",
            },
            {
                target = 115,
                title = "Mageroyal and Briarthorn · 50–115",
                zone = "Darkshore",
                mapID = 1439,
                x = 38.0,
                y = 45.0,
                herbs = "Mageroyal · Briarthorn · Stranglekelp from skill 85",
                instructions = "Darkshore is the Alliance route choice. Loch Modan is a quieter alternative. Train Journeyman at skill 50 before continuing.",
            },
            {
                target = 115,
                title = "Mageroyal and Briarthorn · 70-115",
                zone = "Silverpine Forest",
                herbs = "Mageroyal · Briarthorn · Stranglekelp from skill 85",
                instructions = "Horde option: the lower part supports small loops; mounted characters can follow the main road. The page offers Silverpine for Horde and Loch Modan or Darkshore for Alliance.",
            },
            {
                target = 125,
                title = "Bruiseweed and Wild Steelbloom · 115–125",
                zone = "Hillsbrad Foothills",
                mapID = 1424,
                x = 45.0,
                y = 50.0,
                herbs = "Bruiseweed · Wild Steelbloom",
                instructions = "Farm the lower-risk Hillsbrad areas. Stonetalon Mountains is an alternative, but some pockets have higher-level enemies.",
            },
            {
                target = 150,
                title = "Continue in Hillsbrad · 125–150",
                zone = "Hillsbrad Foothills",
                mapID = 1424,
                x = 45.0,
                y = 50.0,
                herbs = "Bruiseweed · Wild Steelbloom · Kingsblood from skill 125",
                instructions = "Continue the Hillsbrad loop. Train Expert at skill 125 before the profession reaches its 150 cap.",
            },
            {
                target = 170,
                title = "Add Kingsblood and Liferoot · 150–170",
                zone = "Hillsbrad Foothills",
                mapID = 1424,
                x = 45.0,
                y = 50.0,
                herbs = "Kingsblood · Liferoot from skill 150",
                instructions = "Add Kingsblood and Liferoot when their skill requirements are met. Stonetalon is an alternate zone.",
            },
            {
                target = 200,
                title = "Stranglethorn or Arathi · 170–200",
                zone = "Stranglethorn Vale",
                mapID = 1434,
                x = 28.0,
                y = 45.0,
                herbs = "Kingsblood · Liferoot · Fadeleaf · Goldthorn · Khadgar's Whisker from 185",
                instructions = "Use the Stranglethorn route or choose Arathi Highlands if it is more convenient. Prepare to train Artisan at skill 200.",
            },
            {
                target = 205,
                title = "Finish the current route · 200–205",
                zone = "Stranglethorn Vale",
                mapID = 1434,
                x = 28.0,
                y = 45.0,
                herbs = "Kingsblood · Liferoot · Fadeleaf · Goldthorn",
                instructions = "Train Artisan at skill 200, then continue briefly in Stranglethorn or Arathi before moving to Tanaris or Searing Gorge.",
            },
            {
                target = 230,
                title = "Purple Lotus and Firebloom · 205–230",
                zone = "Tanaris",
                mapID = 1446,
                x = 50.0,
                y = 30.0,
                herbs = "Purple Lotus · Firebloom",
                instructions = "Farm Tanaris or Searing Gorge. Neither zone has an Herbalism trainer, so train Artisan before traveling.",
            },
            {
                target = 270,
                title = "The Hinterlands · 230–270",
                zone = "The Hinterlands",
                mapID = 1425,
                x = 60.0,
                y = 50.0,
                herbs = "Sungrass · Purple Lotus · Golden Sansam · Ghost Mushroom from skill 245",
                instructions = "Use the marked cave area for Ghost Mushroom once skill 245 is reached. Continue gathering until 270.",
            },
            {
                target = 300,
                title = "Felwood · 270–300",
                zone = "Felwood",
                mapID = 1448,
                x = 50.0,
                y = 25.0,
                herbs = "Sungrass · Gromsblood · Golden Sansam · Dreamfoil · Mountain Silversage · Plaguebloom",
                instructions = "Continue gathering across Felwood until Herbalism reaches 300.",
            },
        },
    },
}

local herb = WP.RouteData.herbalism
herb.source = "Bundled profession guide"
herb.sourceStatus = "Forever beta-derived. The page warns that high-skill sections may not have been live-tested."
herb.routeNote = "Zone choices are summarized from the source maps; waypoints are broad areas. Use Find Herbs for live nodes."
herb.steps = {
    { target = 70, title = "Herbalism 1-70", zone = "Starting zone", mapID = 2521, x = 46.9, y = 26.0, herbs = "Peacebloom, Silverleaf, Earthroot (15)", instructions = "Choose a starting zone with fast herb respawns. Skyborne can learn Herbalism from the Wild Harvest reward for Harvesting Windstones.", choices = { "Durotar", "Mulgore", "Tirisfal Glades", "Zephras Isle", "Elwynn Forest", "Dun Morogh", "Teldrassil" } },
    { target = 115, title = "Herbalism 70-115", zone = "Silverpine, Loch Modan, or Darkshore", herbs = "Mageroyal, Briarthorn, Stranglekelp (85)", instructions = "Train Journeyman at 50. The guide offers faction-appropriate routes in all three zones.", choices = { "Silverpine Forest", "Loch Modan", "Darkshore" } },
    { target = 170, title = "Herbalism 115-170", zone = "Hillsbrad Foothills or Stonetalon Mountains", mapID = 1424, x = 45.0, y = 50.0, herbs = "Bruiseweed, Wild Steelbloom, Kingsblood (125), Liferoot (150)", instructions = "The guide offers both zones. A +5 Herbalism bonus permits Kingsblood at 120.", choices = { "Hillsbrad Foothills", "Stonetalon Mountains" } },
    { target = 205, title = "Herbalism 170-205", zone = "Stranglethorn Vale or Arathi Highlands", mapID = 1434, x = 28.0, y = 45.0, herbs = "Kingsblood, Liferoot, Fadeleaf, Goldthorn, Khadgar's Whisker (185)", instructions = "Choose the route that suits your travel. Train Artisan at 200 before continuing.", choices = { "Stranglethorn Vale", "Arathi Highlands" } },
    { target = 230, title = "Herbalism 205-230", zone = "Tanaris or Searing Gorge", mapID = 1446, x = 50.0, y = 30.0, herbs = "Purple Lotus, Firebloom", instructions = "Neither zone has an Herbalism trainer; learn Artisan before traveling.", choices = { "Tanaris", "Searing Gorge" } },
    { target = 270, title = "Herbalism 230-270", zone = "The Hinterlands", mapID = 1425, x = 60.0, y = 50.0, herbs = "Sungrass, Purple Lotus, Golden Sansam, Ghost Mushroom (245)", instructions = "The source map includes a cave detour for Ghost Mushroom at 245." },
    { target = 300, title = "Herbalism 270-300", zone = "Felwood", mapID = 1448, x = 50.0, y = 25.0, herbs = "Sungrass, Gromsblood, Golden Sansam, Dreamfoil, Mountain Silversage, Plaguebloom", instructions = "Continue through the Felwood route until 300." },
}
-- Do not hand-author waypoint loops here. Gathered-resource overlays come from
-- imported route records with explicit zone/map coordinates. The guide's zone
-- alternatives remain in the step data and text-only choices are labeled as such.
herb.steps[2].mapRoutes = {}

local function registerGuide(name, slug, sourceStatus, steps, notes, rankGates)
    local key = name:lower():gsub("[^%a]", "")
    local route = {
        name = name, maxSkill = 300, source = "Bundled profession guide",
        sourceStatus = sourceStatus,
        rankGates = rankGates or {
            { skill = 50, cap = 75, rank = "Journeyman" },
            { skill = 125, cap = 150, rank = "Expert" },
            { skill = 200, cap = 225, rank = "Artisan" },
        },
        steps = {},
    }
    for i, step in ipairs(steps) do
        route.steps[i] = { target = step[1], title = step[2], focus = step[3], instructions = step[4], sourceStatus = step[5], recipeOptions = step[6], estimate = step[7] }
    end
    if notes then route.routeNote = notes end
    WP.RouteData[key] = route
end

registerGuide("Alchemy", "alchemy-leveling-guide",
    "Forever beta guide. The page says the 225-300 route is not final; the last 10 points are undecided.", {
        { 10, "Apprentice · 1-10", "9 Minor Arcane Elixirs, or 9 Elixir of Minor Force", "The alternative replaces the whole step if Silverleaf is cheaper. Buy Empty Vials from nearby supply or trade vendors." },
        { 55, "Apprentice · 10-55", "45 Minor Defense Elixirs", "Materials: Silverleaf, Peacebloom and Empty Vials." },
        { 65, "Journeyman · 55-65", "10 Minor Mana Potions", "Train Journeyman at skill 50 and level 10 before passing the 75 cap." },
        { 90, "Journeyman · 65-90", "27 Minor Fortitude Elixirs", "Yellow from 80; the last 10 points may take extra crafts." },
        { 120, "Journeyman · 90-120", "30 Elixirs of Wisdom", "Keep these if also leveling Tailoring; they are used by Gloves of Meditation." },
        { 130, "Journeyman · 120-130", "10 Lesser Mana Potions", "Uses Mageroyal, Stranglekelp and Empty Vials." },
        { 150, "Journeyman · 130-150", "20 Fire Oil", "Each craft yields two. Keep 30 for Elixir of Fire Power. Alternative: Lesser Mana Potion if Firefin Snapper is expensive or unavailable." },
        { 165, "Expert · 150-165", "15 Elixirs of Fire Power", "Uses the saved Fire Oil. Alternative: continue Lesser Mana Potions if you chose that path." },
        { 195, "Expert · 165-195", "36 Mana Potions", "Uses Stranglekelp, Kingsblood and Leaded Vials." },
        { 225, "Expert · 195-225", "36 Nature Protection Potions", "Recipe is bind-on-pickup; the guide lists vendors in Feralas, Stranglethorn and Tanaris." },
        { 230, "Artisan · 225-230", "Nature Protection Potion route continuation", "Guide marks this Classic-derived continuation as untested on Forever live." },
        { 265, "Artisan · 230-265", "Elixir of Greater Mana", "The page gives this route as provisional beta information." },
        { 275, "Artisan · 265-275", "Superior Mana Potion", "Vendor recipe; compare the guide's listed vendors and materials." },
        { 290, "Artisan · 275-290", "Choose Superior Mana, Greater Defense, or Shadow Power", "Compare alternatives against current prices; estimated quantities vary with yellow/green skill-ups." },
        { 300, "Artisan · 290-300", "Merchant's Favor recipe listed by the guide", "The page says the final route is not decided; verify this recipe is available and grants skill before farming." , "Incomplete" },
    }, "Materials are estimates; guide page explicitly marks the upper route as unfinished.")

registerGuide("Blacksmithing", "blacksmithing-leveling-guide",
    "Forever beta-derived route; the guide warns high-skill testing may lag the live game.", {
        { 25, "Apprentice · 1-25", "30 Rough Sharpening Stones", "Uses 30 Rough Stone." },
        { 50, "Apprentice · 25-50", "30 Rough Grinding Stones", "Uses 60 Rough Stone; save 26 for gauntlets and possible Silver Rods." },
        { 67, "Apprentice · 50-67", "36 Coarse Grinding Stones", "Uses 72 Coarse Stone; keep them for bracers later." },
        { 75, "Apprentice · 67-75", "8 Runed Copper Gauntlets", "Uses 64 Copper Bars and 16 saved Rough Grinding Stones; requires Blacksmith Hammer." },
        { 80, "Journeyman · 75-80", "Runed Copper Belts or Silver Rods", "Train Journeyman first. Silver Rod is an alternative when its materials are cheaper." },
        { 95, "Journeyman · 80-95", "18 Runed Copper Belts", "The guide recommends this route in its current Forever version." },
        { 112, "Journeyman · 95-112", "Patterned Bronze Bracers, with Heavy Grinding Stone prep", "Save Heavy Grinding Stones for later recipes; keep remaining Coarse Grinding Stones for this band." },
        { 125, "Journeyman · 112-125", "Patterned Bronze Bracers", "Uses saved Coarse Grinding Stones and Bronze Bars." },
        { 140, "Journeyman · 125-140", "Bronze Shortswords", "Guide favors vendor-sell value; an alternate bracer path is listed for disenchanters." },
        { 170, "Journeyman · 140-170", "Bronze Warhammers", "Buy Strong Flux from a Blacksmithing Supply vendor." },
        { 175, "Expert · 170-175", "Green Iron Bracers", "Train Expert at the 150 cap before continuing." },
        { 215, "Expert · 175-215", "Golden Scale Bracers, then the guide's Steel/Mithril alternatives", "Keep the earlier Heavy Grinding Stones; the detailed route contains alternative branches." },
        { 300, "Artisan · 215-300", "Thorium and Imperial Plate recipe progression", "The guide has multiple recipe alternatives and plan quests; review the live page for exact plan and material branch before buying.", "Branch-heavy: exact materials depend on chosen recipe path." },
    }, "Blacksmithing requires a Blacksmith Hammer; ores and intermediate stones may be gathered or bought.")

registerGuide("Enchanting", "enchanting-leveling-guide",
    "Forever beta-derived; recipe thresholds and material totals should be confirmed in the live profession pane.", {
        { 2, "Apprentice · 1-2", "Runed Copper Rod", "Requires Copper Rod and Mote of Magic; guide says buy these from an Enchanting Supply vendor." },
        { 20, "Apprentice · 2-20", "Enchant Bracer - Inferior Stamina", "Uses Mote of Magic." },
        { 70, "Apprentice · 20-70", "Enchant Chest - Inferior Stamina or Bracer - Minor Deflect", "Choose Strange Dust or Lesser Magic Essence path; Greater Magic Essence can be split into three Lesser." },
        { 100, "Journeyman · 70-100", "Enchant Chest - Minor Absorption", "Train Journeyman before continuing; choose the material branch matching what you bought." },
        { 109, "Journeyman · 100-109", "Continue Chest - Minor Absorption", "Guide uses this to reach the Runed Silver Rod step." },
        { 110, "Journeyman · 109-110", "Runed Silver Rod", "Uses Silver Rod, Strange Dust, Lesser Magic Essence and Shadowgem." },
        { 150, "Journeyman · 110-150", "Follow the guide's selected dust or essence branch", "See the source page for the full spell-by-spell sequence and variant material list." },
        { 225, "Expert · 150-225", "Follow the guide's skill-range enchant sequence", "Expert rank requires its trainer gate; recipe costs depend on dust and essence branch." },
        { 300, "Artisan · 225-300", "Use the source's artisan enchant progression", "Upper guide bands remain beta-derived; confirm each recipe, reagent and skill color in game." },
    }, "The source page includes an optional create/confirm macro. This addon does not automate enchant clicks.")

registerGuide("Engineering", "engineering-leveling-guide",
    "Forever beta-derived; skill-up counts are estimates, especially for yellow recipes.", {
        { 30, "Apprentice · 1-30", "60 Rough Blasting Powder", "Uses 60 Rough Stone; keep all powder for bombs." },
        { 50, "Apprentice · 30-50", "30 Handfuls of Copper Bolts", "Uses Copper Bars; keep bolts for bombs." },
        { 51, "Apprentice · 50-51", "Arclight Spanner", "The guide says to keep this tool for Engineering crafts." },
        { 75, "Journeyman · 51-75", "30 Rough Copper Bombs", "Train Journeyman before unattended crafting; yellow from 60 and may pass 75." },
        { 90, "Journeyman · 75-90", "60 Coarse Blasting Powder", "Save powder for dynamite." },
        { 100, "Journeyman · 90-100", "20 Coarse Dynamite", "Uses saved Coarse Blasting Powder and Linen Cloth." },
        { 105, "Journeyman · 100-105", "Silver Contacts or Flying Tiger Goggles", "Goggles are the alternative when Silver Bars are expensive." },
        { 125, "Journeyman · 105-125", "25 Bronze Tubes", "Yellow throughout; if short, begin scopes rather than making extra tubes." },
        { 135, "Journeyman · 125-135", "10 Standard Scopes", "Uses Bronze Tubes and Moss Agate; Heavy Blasting Powder is an alternative." },
        { 150, "Journeyman · 135-150", "Heavy Blasting Powder and Whirring Bronze Gizmos", "Make both in the guide's order; both are needed for the later sheep recipe." },
        { 160, "Expert · 150-160", "Bronze Frameworks", "Keep all 15 for the sheep recipe." },
        { 200, "Expert · 160-200", "Continue the guide's sheep and device sequence", "The source gives prerequisite chains; keep intermediate parts and check exact quantities on the page." },
        { 300, "Artisan · 200-300", "Follow the source's upper Engineering recipe sequence", "The detailed high-skill route has multiple components and recipe steps; verify recipe availability and amounts before shopping." },
    }, "Mining supplies much of Engineering's ore and stone. The Forever guide says Gnomes no longer get a flat Engineering skill bonus.")

registerGuide("Leatherworking", "leatherworking-leveling-guide",
    "Forever beta-derived; yellow recipe counts and upper skill alternatives may require extra crafts.", {
        { 30, "Apprentice · 1-30", "Light Armor Kits", "The source offers scraps processing or a Light Leather alternative." },
        { 45, "Apprentice · 30-45", "Light Armor Kits or Cured Light Hides", "Cured Light Hides are an alternative if you bought Light Hides; save hides for later pants." },
        { 55, "Apprentice · 45-55", "Embossed Leather Gloves", "Skip this if using the cured-hide branch through 55." },
        { 75, "Journeyman · 55-75", "Embossed Leather Gloves", "Train Journeyman before passing 75." },
        { 80, "Journeyman · 75-80", "Medium Leather", "The guide makes Medium Leather from Light Leather." },
        { 90, "Journeyman · 80-90", "Cured Medium Hides or Fine Leather Belts", "Choose according to whether you have Medium Hides or bought Medium Leather; save cured hides." },
        { 100, "Journeyman · 90-100", "Fine Leather Belts", "Keep 10 for Dark Leather Belts." },
        { 115, "Journeyman · 100-115", "Dark Leather Cloaks or Light Leather Pants", "Use the Light Leather Pants alternative if following the Light Hide path." },
        { 125, "Journeyman · 115-125", "Dark Leather Belts or Pants and Hillman's Gloves", "Branch depends on whether Medium Leather or Medium Hides were purchased." },
        { 130, "Expert · 125-130", "Heavy Leather", "Train Expert at skill 125 and level 20." },
        { 210, "Expert · 130-210", "Cured Heavy Hide or no-hide route", "Choose using the guide's material-cost comparison; route includes several recipe alternatives." },
        { 300, "Artisan · 210-300", "Nightscape, Wicked and Runic Leather recipes", "The upper route includes pattern choices; use the source guide for current alternatives and recipe vendors." },
    }, "Skinning pairs with Leatherworking. The source route has hide-versus-leather choices; materials vary by path.")

registerGuide("Tailoring", "tailoring-leveling-guide",
    "Forever beta guide; page notes its 225+ shopping data is incomplete and yellow recipe counts are estimates.", {
        { 55, "Apprentice · 1-55", "Linen Cloth crafts", "The source says Tailoring Supply vendors near trainers sell thread and dyes; Brill is the Tirisfal exception." },
        { 80, "Journeyman · 55-80", "45 Bolts of Woolen Cloth", "Learn Journeyman before crafting; save bolts for later and optionally make the full 153 needed through skill 140." },
        { 95, "Journeyman · 80-95", "Woolen Capes", "If bolts already raised skill past 80, continue capes to 95." },
        { 100, "Journeyman · 95-100", "Double-stitched Woolen Shoulders", "Uses Woolen Cloth bolts and Fine Thread." },
        { 120, "Journeyman · 100-120", "54 Bolts of Silk Cloth", "Keep them for later crafts; making 184 bolts now covers the guide through skill 190." },
        { 125, "Journeyman · 120-125", "Gloves of Meditation", "Requires Woolen Cloth bolts, Fine Thread and Elixir of Wisdom." },
        { 140, "Expert · 125-140", "Gloves of Meditation", "Yellow throughout; may need extra. Train Expert at skill 125 and level 20." },
        { 150, "Expert · 140-150", "Bolts of Mageweave", "The source says total bolts required through 225 can be made early." },
        { 170, "Expert · 150-170", "Crimson Silk Vest", "Uses Silk bolts, Red Dye and Fine Thread." },
        { 190, "Expert · 170-190", "Crimson Silk Pantaloons", "Yellow from 180; may require extra crafts." },
        { 215, "Expert · 190-215", "Black Mageweave Gloves", "Yellow from 195 and green from 210." },
        { 225, "Expert · 215-225", "Mageweave Bags", "Uses Mageweave bolts and Silken Thread." },
        { 265, "Artisan · 225-265", "Runecloth Belts then Runecloth Gloves", "Source shopping list stops at 265 and says later route/prices are unfinished." , "Incomplete above 265" },
        { 300, "Artisan · 265-300", "Live recipe required", "The source has not published a finished 265-300 route; choose only recipes the live window confirms will skill up.", "Not provided by source" },
    }, "Use the live profession pane to verify recipe skill-up colors; source does not finish the final range.")

registerGuide("Mining", "mining-leveling-guide",
    "The Forever page gives current routes through its skill brackets, then identifies Classic-derived sections that may change.", {
        { 65, "Copper · 1-65", "Copper Veins or smelting", "Starting-zone choice; the guide discusses Durotar, Mulgore, Tirisfal, Elwynn, Dun Morogh, Teldrassil and Zephras Isle. Buy a Mining Pick." },
        { 125, "Copper/Tin · 65-125", "Tin and Copper; optional smelting", "Guide lists cave and open-route choices by faction. Tin requires 65; Silver 75; Iron 125." },
        { 175, "Iron/Gold · 125-175", "Iron Deposits and Gold Veins", "Zone choices include Arathi Highlands, Thousand Needles and Desolace. Gold requires 155." },
        { 245, "Mithril · 175-245", "Mithril and Truesilver", "Guide choices include The Hinterlands and Tanaris; Truesilver requires 230." },
        { 275, "Mithril/Thorium · 245-275", "Small Thorium Veins", "Guide choices include Un'Goro, Blasted Lands and Felwood; small Thorium requires 245." },
        { 300, "Thorium · 275-300", "Rich Thorium Veins", "Choices include Un'Goro, Eastern Plaguelands, Winterspring and Burning Steppes; Rich Thorium requires 275." },
    }, "The guide has smelting and mining alternatives through 120; exact mining spawn pins are not included here.")

local function addMapSteps(key, coordinates)
    local route = WP.RouteData[key]
    if not route then return end
    for i, point in ipairs(coordinates) do
        local step = route.steps[i]
        if step then step.mapID, step.x, step.y = point[1], point[2], point[3] end
    end
end
addMapSteps("mining", { {12,46,66}, {1432,50,52}, {1417,48,48}, {1425,52,48}, {1449,50,50}, {1452,48,52} })
registerGuide("Skinning", "skinning-leveling-guide",
    "Forever beta-derived; the page says high-skill testing takes time and may need live updates.", {
        { 75, "Skinning · 1-75", "Skin low-level beasts in your starting zone", "Guide includes Durotar, Mulgore, Tirisfal, Skyborne Zephras Isle, Elwynn, Dun Morogh and Teldrassil. Skyborne can learn it through the Pelt Collecting for Beginners quest reward." },
        { 150, "Skinning · 75-150", "Progress through the guide's faction zone choices", "Alliance uses Loch Modan then Wetlands; Horde follows the guide's Barrens route. Check mob skinning-skill requirement." },
        { 225, "Skinning · 150-225", "Foothill Caverns yetis or Duskwood route", "The page presents alternative zones for this band; pick based on faction and travel." },
        { 280, "Skinning · 225-280", "Feral Scar Vale yetis in Feralas", "Check the source page's mob skinning requirements before farming." },
        { 300, "Skinning · 280-300", "Western Un'Goro dinosaurs", "Use the live skill value and skin mobs that meet the source's requirements." },
    }, "No exact mob spawn coordinates are bundled; this route uses zone-level guidance.")

addMapSteps("skinning", { {12,46,66}, {1437,50,50}, {1431,48,52}, {1444,50,48}, {1449,52,52} })

registerGuide("First Aid", "first-aid-leveling-guide",
    "Forever beta-derived; source labels upper material estimates provisional and skill-ups may vary.", {
        { 75, "Apprentice · 1-75", "Linen Bandages or First Aid healing potions", "First Aid is secondary and can be learned by every character; source includes a Peacebloom alternative." },
        { 150, "Journeyman · 75-150", "Wool Bandages", "Guide lists the recipe/trainer steps; stop to train before passing the current cap." },
        { 225, "Expert · 150-225", "Silk then Mageweave Bandages", "Counts are estimates; yellow recipes can need extra cloth and crafts." },
        { 300, "Artisan · 225-300", "Mageweave/Runecloth Bandages and Forever healing recipes", "The page marks this shopping segment unfinished; verify recipe source and materials before buying." , "Upper list provisional" },
    }, "Forever moved certain healing potions from Alchemy to First Aid.")

registerGuide("Cooking", "cooking-leveling-guide",
    "Forever beta-derived; recipe counts are estimates, yellow recipes may need extra crafts, and alternatives replace one another.", {
        { 50, "Apprentice 1-50", "Choose ONE: Brilliant Smallfish, Slitherskin Mackerel, Charred Wolf Meat, Roasted Boar Meat, or Herb Baked Egg", "About 55 crafts estimated. Fish recipes need raw fish; meat recipes need matching meat; Herb Baked Egg needs Small Eggs and Mild Spices. Do not add alternatives together.", nil, "Brilliant Smallfish OR Slitherskin Mackerel OR Charred Wolf Meat OR Chunk of Boar Meat OR Small Egg + Mild Spices", "~55 crafts; estimate" },
        { 100, "Journeyman 50-100", "Choose ONE: Longjaw Mud Snapper, Rainbow Fin Albacore, Smoked Bear Meat, or another listed branch", "About 55 fish crafts estimated; Smoked Bear Meat is estimated at 65-75 Bear Meat. Learn Journeyman at 50. Campfire may be required; use a trainer fire or Campfire Kit.", nil, "Raw Longjaw Mud Snapper OR Raw Rainbow Fin Albacore OR Bear Meat + Mild Spices", "~55 fish crafts / ~65-75 Bear Meat; estimate" },
        { 130, "Journeyman 100-130", "Choose ONE: Bristle Whisker Catfish or a listed crab/crawler meat recipe", "About 30-40 crafts estimated. If choosing Catfish, catch extra now for 130-150; saved catches are carried forward, not counted again as shopping needs.", nil, "Raw Bristle Whisker Catfish OR one crab/crawler recipe branch", "~30-40 crafts; estimate" },
        { 150, "Journeyman 130-150", "Choose ONE: Bristle Whisker Catfish, Curiously Tasty Omelet, Goblin Deviled Clams, or Hot Lion Chops", "Expert Cooking comes from the Expert Cookbook at 125 (Alliance: Ashenvale; Horde: Desolace). Buy and read it before the 150 cap.", nil, "Raw Bristle Whisker Catfish OR Raptor Egg + Hot Spices OR clam ingredients OR Lion Meat + Hot Spices", "~20-25 crafts; estimate" },
        { 175, "Expert 150-175", "Choose ONE: Curiously Tasty Omelet or Hot Lion Chops", "Use the recipe branch matching materials on hand. This standalone guide does not require leveling Fishing.", nil, "Raptor Egg + Hot Spices OR Lion Meat + Hot Spices", "~25 crafts; estimate" },
        { 225, "Expert 175-225", "Choose ONE: Mithril Headed Trout, Roast Raptor, or Soothing Turtle Bisque", "About 50 crafts estimated. Mithril Headed Trout uses raw fish; Roast Raptor uses Raptor Flesh and Hot Spices. Soothing Turtle Bisque requires its quest recipe.", nil, "Raw Mithril Head Trout OR Raptor Flesh + Hot Spices OR quest recipe ingredients", "~50 crafts; estimate" },
        { 275, "Artisan 225-275", "Choose ONE: Spotted Yellowtail, Filet of Redgill, Undermine Clam Chowder, Monster Omelet, or Tender Wolf Steak", "Artisan Cooking requires Clamlette Surprise at Cooking 225 and level 35. Source estimates about 65 crafts of one selected recipe; branches are alternatives.", nil, "One recipe branch only: fish OR clam OR Monster Omelet OR Tender Wolf Steak ingredients", "~65 crafts; estimate" },
        { 300, "Artisan 275-300", "Choose ONE: Poached Sunscale Salmon or Nightfin Soup; source also lists a quest recipe alternative", "About 35 crafts estimated. Fish recipes turn yellow at 290, so extra crafts may be needed. This is not a guaranteed shopping total.", nil, "Raw Sunscale Salmon OR Raw Nightfin Snapper + Refreshing Spring Water OR quest branch", "~35 crafts; estimate; yellow from 290" },
    }, "Standalone Cooking follows Cooking skill only. Recipes are alternatives; Fishing is not required unless a fish recipe is selected.", {
        { skill = 50, cap = 75, rank = "Journeyman", zone = "Any Cooking trainer", note = "Train Journeyman before continuing beyond the 75 cap." },
        { skill = 125, cap = 150, rank = "Expert", zone = "Ashenvale (Alliance) or Desolace (Horde)", note = "Buy and read the Expert Cookbook before continuing past the 150 cap." },
        { skill = 225, cap = 225, rank = "Artisan", zone = "Gadgetzan, Tanaris", note = "Complete Clamlette Surprise. Requires Cooking 225, level 35, 12 Giant Eggs, 10 Zesty Clam Meat, and 20 Alterac Swiss." },
    })

registerGuide("Fishing", "fishing-leveling-guide",
    "Forever beta-derived; fish quantities are estimates and the Artisan quest is a required progression stop.", {
        { 75, "Fishing · 1-75", "Starting-zone water route", "Guide lists pole, lure and starting-zone choices; each includes trainer/vendor and fishing area." },
        { 150, "Fishing · 75-150", "Capital-city fishing route", "Choose a route based on faction/travel; the page provides fish expectations and recipe stops." },
        { 205, "Fishing · 150-205", "Progress through source water zones", "Requires Expert/Artisan progression and guide-specified book or quest steps." },
        { 255, "Fishing · 205-255", "Continue route and complete Artisan Fishing quest", "Guide includes quest items and turn-in; check requirements before traveling." },
        { 300, "Fishing · 255-300", "Feralas fishing route", "Use the standalone Fishing guide, or Fishing+Cooking if raising Cooking in parallel." },
    }, "Fishing has no craft recipes; route advances from the live Fishing skill value.")

-- Fishing location pins and route stops adapted from the user's supplied
-- ZygorProfessionsAllianceCLASSIC.lua. These are fishing access points, not
-- guaranteed pool spawns; open-water locations can move with server changes.
local fishing = WP.RouteData.fishing
fishing.routeNote = "Fishing spots mark water access points, not guaranteed school spawns."
fishing.steps[1].zone, fishing.steps[1].mapID, fishing.steps[1].x, fishing.steps[1].y = "Elwynn Forest", 1429, 33.70, 62.97
fishing.steps[1].focus = "Train in Stormwind; fish Elwynn waters to 75; keep Shiny Baubles active."
fishing.steps[1].mapRoutes = {
    ["Elwynn Forest"] = { mapID=1429, points={{33.70,62.97},{33.59,63.52}} },
    ["Teldrassil"] = { mapID=1438, points={{56.25,93.72}} },
}
fishing.steps[2].zone, fishing.steps[2].mapID, fishing.steps[2].x, fishing.steps[2].y = "Stormwind City", 1453, 55.24, 69.73
fishing.steps[2].focus = "Train Journeyman at 75; fish Stormwind, then Redridge to 150; use Nightcrawlers."
fishing.steps[2].mapRoutes = {
    ["Stormwind City"] = { mapID=1453, points={{55.09,69.76},{54.78,68.96},{55.24,69.73}} },
    ["Redridge Mountains"] = { mapID=1433, points={{24.60,56.28}} },
}
fishing.steps[3].zone, fishing.steps[3].mapID, fishing.steps[3].x, fishing.steps[3].y = "Stranglethorn Vale", 1434, 27.64, 76.67
fishing.steps[3].focus = "Buy Expert Fishing - The Bass and You from Old Man Heming; fish to 225 with Bright Baubles."
fishing.steps[3].mapRoutes = {
    ["Stranglethorn Vale"] = { mapID=1434, points={{27.42,77.16},{27.64,76.67},{26.22,73.57}} },
}
fishing.steps[4].zone, fishing.steps[4].mapID, fishing.steps[4].x, fishing.steps[4].y = "Dustwallow Marsh", 1445, 58.55, 60.21
fishing.steps[4].focus = "At level 35, start Nat Pagle's Artisan Fishing quest; catch one quest fish in each of four zones."
fishing.steps[4].mapRoutes = {
    ["Dustwallow Marsh"] = { mapID=1445, points={{58.55,60.21}} },
    ["Feralas"] = { mapID=1444, points={{62.38,52.50}} },
    ["Desolace"] = { mapID=1443, points={{38.96,22.70}} },
    ["Swamp of Sorrows"] = { mapID=1435, points={{90.45,73.47}} },
    ["Stranglethorn Vale"] = { mapID=1434, points={{24.58,65.80}} },
}
fishing.steps[5].zone, fishing.steps[5].mapID, fishing.steps[5].x, fishing.steps[5].y = "The Hinterlands", 1425, 29.50, 47.82
fishing.steps[5].focus = "Follow the road through the zone to the water; fish from 255 to 300 with Bright Baubles."
fishing.steps[5].mapRoutes = { ["The Hinterlands"] = { mapID=1425, points={{18.57,53.61},{28.61,53.02},{29.50,47.82}} } }

registerGuide("Fishing + Cooking", "fishing-and-cooking-leveling-guide",
    "Forever beta-derived combined route; catch counts and Cooking skill-ups are estimates; source marks high-level section Classic-derived.", {
        { 75, "Fishing · 1-75", "Choose a starting-zone route and cook the catch", "Guide recommends Mulgore for Horde and Elwynn Forest for Alliance; it also includes Durotar, Tirisfal, Zephras, Dun Morogh and Teldrassil." },
        { 130, "Fishing · 75-130 / Cooking · 1-100", "Fish in a capital and cook small fish/Longjaw", "The guide offers capital choices and tells you which catches and recipes to keep." },
        { 205, "Fishing · 130-205 / Cooking · 100-175", "Continue capital/zone fishing and cook catches", "Follow the guide's sequential steps; caught fish supply cooking so avoid buying the same fish twice." },
        { 225, "Artisan Fishing quest", "Complete the Fishing quest step", "Collect the guide-listed items, including lure/quest supplies, before travel." },
        { 255, "Fishing · 205-255 / Cooking · 175-225", "Continue route and cook the catches", "Guide includes the Artisan Cooking quest in this sequence." },
        { 300, "Fishing · 255-300 / Cooking · 225-300", "Finish fishing in Feralas and choose a final cooking recipe", "The page offers a choice of Sunscale Salmon or Nightfin Soup; high-skill route is marked Classic-derived." },
    }, "Combined route tracks both Fishing and Cooking. This summary does not yet subtract fish caught from an itemized shopping list.", {}, {})

WP.RouteData.fishingcooking.skills = {
    Fishing = { skill = 0, maxSkill = 300 },
    Cooking = { skill = 0, maxSkill = 300 },
}
WP.RouteData.fishingcooking.name = "Cooking with Fishing"
WP.RouteData.fishingcooking.mode = "cookingfishing"
WP.RouteData.fishingcooking.source = "Bundled profession guide"
WP.RouteData.fishingcooking.steps = {
    { skill="Cooking", from=0, target=50, title="Cooking 1-50: starting fish recipes", zone="Cooking fire", fish="Raw Brilliant Smallfish or Raw Slitherskin Mackerel", fishingTarget=75, fishingChoices={"Mulgore","Durotar","Tirisfal Glades","Zephras Isle","Elwynn Forest","Dun Morogh","Teldrassil"}, focus="Cook fish you already caught; either fish recipe is a choice, not an additive shopping requirement.", instructions="The guide estimates about 55 crafts for this band. If you are short, catch and cook more. Keep other catches for later Cooking steps." },
    { skill="Cooking", from=50, target=100, title="Cooking 50-100: Longjaw Mud Snapper", zone="Cooking fire", fish="Raw Longjaw Mud Snapper", fishingTarget=130, fishingChoices={"Stormwind City","Thunder Bluff","Undercity","Orgrimmar"}, focus="Cook saved Longjaw Mud Snapper. The source says later fishing can supply more if Cooking is still short.", instructions="Learn Journeyman Cooking at skill 50 before continuing. Fish in a nearby capital for the catch." },
    { skill="Cooking", from=100, target=130, title="Cooking 100-130: Bristle Whisker Catfish or meat recipe", zone="Cooking fire", fish="Raw Bristle Whisker Catfish (choice); meat recipes are alternatives", fishingTarget=130, fishingChoices={"Stormwind City","Thunder Bluff","Undercity","Orgrimmar"}, focus="Choose one recipe branch based on catches you actually have; do not add alternatives together.", instructions="The guide suggests roughly 30-40 crafts. It recommends catching extra Catfish now for skill 130-150." },
    { skill="Cooking", from=130, target=150, title="Cooking 130-150: Catfish or non-fish alternatives", zone="Cooking fire", fish="Raw Bristle Whisker Catfish (choice); Curiously Tasty Omelet / clam / lion recipes are alternatives", fishingTarget=205, fishingChoices={"Stonetalon Mountains","Ashenvale"}, focus="Cook remaining Catfish if following the fish branch; other recipes replace this branch.", instructions="Expert Cooking is taught by the Expert Cookbook at 125. The source estimates about 20-25 crafts for this band." },
    { skill="Cooking", from=150, target=175, title="Cooking 150-175: fish or meat recipe choice", zone="Cooking fire", fish="Mithril Head Trout becomes a later fish option; Curiously Tasty Omelet or Hot Lion Chops are listed here", fishingTarget=205, fishingChoices={"Stonetalon Mountains","Ashenvale"}, focus="The guide's 150-175 recipes are alternatives. The fish recipe is part of the following band; use ingredients actually available.", instructions="Expert Cooking requires skill 125 and the Expert Cookbook. Confirm the cookbook is learned before cooking past the cap." },
    { skill="Cooking", from=175, target=225, title="Cooking 175-225: Mithril Head Trout or meat recipes", zone="Cooking fire", fish="Raw Mithril Head Trout; Roast Raptor or Soothing Turtle Bisque are alternatives", fishingTarget=255, fishingChoices={"Dustwallow Marsh","Feralas","Desolace","Swamp of Sorrows","Stranglethorn Vale"}, focus="Use one recipe branch. If fishing, save quest fish and catch materials needed for the Artisan Fishing step.", instructions="The guide estimates about 50 crafts; recipes turn yellow near the end. Finish the Artisan Fishing quest separately if you are also raising Fishing." },
    { skill="Cooking", from=225, target=300, title="Cooking 225-300: artisan fish recipes", zone="Cooking fire", fish="Spotted Yellowtail or Filet of Redgill; recipes are alternatives", fishingTarget=300, fishingChoices={"Feralas"}, focus="Fishing to 300 in Feralas can supply the fish branch. Keep caught fish reserved for Cooking before shopping for more.", instructions="Learn Artisan Cooking from the Clamlette Surprise quest at level 35 and Cooking 225. The upper route is marked untested on the source page; verify recipes and skill-ups in game." },
}
WP.RouteData.fishingcooking.routeNote = "Cooking is the tracked skill in this guide. Fishing remains a separate profession: its live skill is shown as a fish-supply dependency, and map options point to fish routes. The standalone Fishing guide tracks Fishing by itself. Recipe alternatives replace one another; no fish is treated as bought when already caught."
WP.RouteData.fishingcooking.onHold = true
WP.RouteData.fishingcooking.holdNote = "Combined Fishing + Cooking guide paused by user; use the standalone Cooking and Fishing guides for now."
WP.RouteData.fishingcooking.skills.Fishing = WP.professions and WP.professions.Fishing or WP.RouteData.fishingcooking.skills.Fishing
WP.RouteData.fishingcooking.skills.Cooking = WP.professions and WP.professions.Cooking or WP.RouteData.fishingcooking.skills.Cooking

-- Explicit source carry-forward notes. These are preservation instructions, not
-- an inventory ledger or guaranteed shopping quantities.
local function addCarryForward(routeKey, stepIndex, note)
    local route = WP.RouteData[routeKey]
    local step = route and route.steps and route.steps[stepIndex]
    if step then step.carryForward = note end
end

addCarryForward("alchemy", 7, "Reserve 30 Fire Oil for Elixir of Fire Power. This is a planned intermediate, not surplus.")
addCarryForward("alchemy", 8, "Use the Fire Oil reserved from the prior step; do not add those saved units again to shopping totals.")
addCarryForward("blacksmithing", 2, "Carry 26 Rough Grinding Stones forward for Runed Copper Gauntlets; the source also notes possible Silver Rod use.")
addCarryForward("blacksmithing", 3, "Keep the produced Coarse Grinding Stones for the later bracer steps; the source calls for 36 here.")
addCarryForward("blacksmithing", 7, "Keep Heavy Grinding Stones for later recipes and carry any unused Coarse Grinding Stones forward.")
addCarryForward("engineering", 1, "Keep the Rough Blasting Powder for the later bomb steps.")
addCarryForward("engineering", 2, "Keep the Copper Bolts for the bomb sequence.")
addCarryForward("engineering", 3, "Keep the Arclight Spanner; later Engineering recipes require it as a tool.")
addCarryForward("engineering", 5, "Keep the Coarse Blasting Powder for Coarse Dynamite.")
addCarryForward("tailoring", 2, "Keep Woolen Cloth Bolts for later crafts. The source says an early larger batch can cover through skill 140.")
addCarryForward("tailoring", 5, "Keep Silk Cloth Bolts for later recipes. The source says 184 bolts cover the guide through skill 190.")
addCarryForward("tailoring", 6, "Use reserved Woolen Cloth Bolts and any saved Elixir of Wisdom; do not count those carried materials as new purchases.")
addCarryForward("cooking", 3, "If you chose the Catfish branch, reserve the extra catches for Cooking 130-150. Already caught fish are not new shopping needs.")
addCarryForward("cooking", 4, "Use Catfish reserved from the prior step before adding more fish to the shopping list.")
addCarryForward("fishingcooking", 1, "Keep fish catches needed by the upcoming Cooking steps; caught fish should not be counted again as shopping purchases.")
addCarryForward("fishingcooking", 3, "Keep the named fish needed for the following Cooking steps and track Fishing/Cooking progress independently.")
addCarryForward("fishingcooking", 5, "Cook fish already caught for the guide before adding fish to any shopping list.")


