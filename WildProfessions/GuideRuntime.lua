local _, WP = ...

local function normalizeProfession(name)
    if type(name) ~= "string" then return nil end
    return name:lower():gsub("[^%a]", "")
end

local ZONE_MAP_IDS = {
    ["Durotar"] = 1411, ["Mulgore"] = 1412, ["Tirisfal Glades"] = 1420,
    ["Elwynn Forest"] = 1429, ["Dun Morogh"] = 1426, ["Teldrassil"] = 1438,
    ["Silverpine Forest"] = 1421, ["Loch Modan"] = 1432, ["Darkshore"] = 1439,
    ["The Barrens"] = 1413, ["Barrens"] = 1413, ["Hillsbrad Foothills"] = 1424,
    ["Stonetalon Mountains"] = 1442, ["Stranglethorn Vale"] = 1434,
    ["Arathi Highlands"] = 1417, ["Tanaris"] = 1446, ["Searing Gorge"] = 1427,
    ["The Hinterlands"] = 1425, ["Felwood"] = 1448,
}

local function zoneChoiceKey(profession, stepIndex)
    local name = type(profession) == "table" and profession.name or profession
    local key = normalizeProfession(name) or "unknown"
    return key .. ":" .. tostring(stepIndex or 0)
end

local function findFarmRoute(route, zone, skill)
    local wanted = type(zone) == "string" and zone:lower() or ""
    local best
    for _, farm in ipairs(route and route.farmRoutes or {}) do
        if type(farm.zone) == "string" and farm.zone:lower() == wanted
            and (not farm.skill or farm.skill <= (tonumber(skill) or 0)) then
            if not best or (tonumber(farm.skill) or 0) > (tonumber(best.skill) or 0) then best = farm end
        end
    end
    local routeKey = normalizeProfession(route and route.name) or ""
    for _, farm in ipairs(WP.ZygorGatheringIndex and WP.ZygorGatheringIndex[routeKey] or {}) do
        if farm.zone and farm.zone:lower() == wanted and (not farm.skill or farm.skill <= (tonumber(skill) or 0)) then
            if not best or (tonumber(farm.skill) or 0) > (tonumber(best.skill) or 0) then best = farm end
        end
    end
    return best
end

function WP:ShowSystemGuide(kind)
    if not self.mainFrame then self:CreateUI() end
    self.systemGuideKind = kind == "merchants" and "merchants" or "camping"
    if self.mainFrame then self.mainFrame:Show() end
    if self.systemGuideButton then
        self.systemGuideButton:SetText(self.systemGuideKind == "camping" and "Camping Guide" or "Merchant's Favor")
    end
    if self.systemGuideText then
        if self.systemGuideKind == "camping" then
            self.systemGuideText:SetText(table.concat({
                "CAMPING — SOURCE GUIDE SUMMARY",
                "",
                "Place a campfire, contribute one camp item per player, then /sit beside it for about a minute. Camp Benefits lasts one hour; your camp items share a one-hour cooldown. Kits hold 3, 5, or 10 items. These effects do not stack with matching class buffs. The Great Outdoors and Camping 101 quests are optional; quest-giver fires also grant Camp Tent rested XP.",
                "",
                "CAMPFIRE KITS",
                "Basic: Cooking skill 1; 3 slots; recipe comes with Cooking and uses 1 Simple Wood. Journeyman: learn at 90, use at 140; 5 slots; 1 Star Wood; Blueprint drops from Lord Serpentis in Wailing Caverns. Expert: learn at 200, use at 220; 10 slots; 1 Thick Logs; the source did not know its blueprint drop location.",
                "",
                "PROFESSION CAMP ITEMS",
                "Each profession item unlocks at skill 20, 140, and 300 (Cooking has two). Tier 1 comes from a trainer or Camping 101; tiers 2 and 3 require blueprints. Tier 2 blueprints are dungeon drops; the source leaves some tier 3 sources unknown. Higher tiers still provide the profession's tier 1 buff; whether tier 3 also includes tier 2 utility is unconfirmed.",
                "",
                "Tier 1 effects: Alchemy mana regeneration; Blacksmithing strength; Enchanting armor/stats/resistance; Engineering reagent vendor; Leatherworking rested XP; Tailoring faction spirit; Herbalism intellect; Mining melee attack power; Skinning critical strike; First Aid stamina; Fishing all attributes. Cooking supplies the campfire.",
                "Tier 2 stations include Alchemy Fermenter, Blacksmith Anvil, Enchanting Arcane Salvager, Engineering Repair Bot, Leatherworking Tanning Rack, Tailoring Spinning Wheel, Herbalism Greenhouse, Mining ore node, Skinning Track Beasts utility, Cooking shared feast, First Aid healing station, and Fishing station. Tier 3 adds profession workstations or utilities such as Alchemy Lab, Master Forge, Arcane Forge, Loom, Sewing Machine, and advanced Fishing/Cooking stations.",
                "",
                "Recipe station requirements and blueprint drops are guide-derived, not confirmed live. Check the linked source for exact item recipes and materials."
            }, "\n"))
        else
            self.systemGuideText:SetText(table.concat({
                "MERCHANT'S FAVOR — SOURCE GUIDE SUMMARY",
                "",
                "The currency is character-bound. Both faction camps sell the same profession and Cooking recipe catalog. Horde: Durotar Supply and Logistics, in The Barrens just west of the Crossroads gate. Alliance: Azeroth Commerce Authority at Three Corners on the west edge of Redridge Mountains.",
                "",
                "WAYLAID CRATES — FAVOR",
                "Crates can drop randomly in the world. A crate accepts one of the listed material bundles, not every alternative in its row; filling seals and binds it. Turn it in to Dokimi (Horde) or Marcy Baker (Alliance). Crates award Merchant's Favor plus silver; crate turn-ins do not award reputation. White/green crate payouts vary by rank. The source did not know blue or elite crate rewards.",
                "Apprentice crates: character level 10; common bundles include Linen Cloth/Light Leather, Copper/Tin Ore, low-level herbs, enchanting materials, Cured Light Hide/Linen Bolts, Copper/Tin/Bronze Bars, or Engineering parts. Journeyman crates also require level 10 and use Wool/Silk/Medium Leather, Silver/Iron, Journeyman herbs/materials, bolts/hides, bars, or Engineering components. Expert crates require level 20; Artisan crates require level 35.",
                "",
                "CRAFTSMAN'S WRITS — REPUTATION",
                "Writs ask for an item to deliver to a marked customer. Journeyman, Expert, and Artisan writs give 75, 125, and 200 reputation respectively, plus a coin pouch. Each specific writ is repeatable once per day; different writs can be done on the same day. Writs do not award Merchant's Favor. The Shipping Label quest is reported to award 2,000 reputation and 50 Favor.",
                "At Friendly, an Uncertified Scribe offers a receipt to convert an empty crate into reputation; at Honored, a quill can reroll a writ into another of its rank. Verify current costs and behavior at the camp.",
                "",
                "VENDOR REWARDS",
                "The source lists recipes by profession with skill, character-level, Favor cost, and reputation requirements, plus a mount, pet, tabard, and titles. This build summarizes the system but does not include the full changing vendor table. Check the linked source or camp vendors for exact item names and current costs."
            }, "\n"))
        end
        self.systemGuideText:Show()
    end
end

function WP:SetGuideZone(zone)
    local state = self:GetCurrentGuideState()
    if not state or not state.stepIndex or type(zone) ~= "string" then return false end
    self:EnsureDatabase()
    self.db.settings.guideZones = self.db.settings.guideZones or {}
    self.db.settings.guideZones[zoneChoiceKey(state.profession, state.stepIndex)] = zone
    self:UpdateDashboard()
    self:UpdateTracker()
    if self.RefreshMapOverlay then self:RefreshMapOverlay() end
    if self.UpdateGuideArrow then self:UpdateGuideArrow() end
    local stateAfter = self:GetCurrentGuideState()
    if stateAfter and stateAfter.mapID then
        if self.mapRoutesVisible and self.attachMapOverlay then self.attachMapOverlay() end
    end
    return true
end

function WP:CycleGuideZone()
    local state = self:GetCurrentGuideState()
    local choices = state and state.choices or {}
    if #choices < 2 then
        self:Print("This step has no alternate zones.")
        return
    end
    local current = state.selectedZone or state.zone
    local index = 0
    for i, name in ipairs(choices) do if name == current then index = i; break end end
    local nextZone = choices[index % #choices + 1]
    self:SetGuideZone(nextZone)
    self:Print("Route zone: " .. nextZone)
end

function WP:SetGatheringRoute(entry, professionName)
    if type(entry) ~= "table" or not entry.mapID or type(entry.points) ~= "table" then return false end
    self:EnsureDatabase()
    local key = normalizeProfession(professionName or self.selectedProfession)
    if not key then return false end
    self.db.settings.gatheringRoutes = self.db.settings.gatheringRoutes or {}
    self.db.settings.gatheringRoutes[key] = {
        zone = entry.zone, mapID = entry.mapID, points = entry.points,
        skill = entry.target, bracket = entry.bracket, item = entry.item, faction = entry.faction,
    }
    self.selectedGatheringProfession = key
    self.selectedGatheringRoute = self.db.settings.gatheringRoutes[key]
    self.mapRoutesVisible = true
    if self.UpdateDashboard then self:UpdateDashboard() end
    if self.UpdateTracker then self:UpdateTracker() end
    if self.RefreshMapOverlay then self:RefreshMapOverlay() end
    if self.UpdateGuideArrow then self:UpdateGuideArrow() end
    return true
end

function WP:GetGuideRoute(profession)
    local name = type(profession) == "table" and profession.name or profession
    local key = normalizeProfession(name)
    if key == "fishingcooking" then
        local route = WP.RouteData and WP.RouteData.fishingcooking
        if route and route.onHold then return nil end
        if route and route.skills then
            route.skills.Fishing = self.professions.Fishing or route.skills.Fishing
            route.skills.Cooking = self.professions.Cooking or route.skills.Cooking
        end
        return route
    end
    return key and WP.RouteData and WP.RouteData[key] or nil
end

function WP:GetGuideState(profession)
    if not profession then
        return { status = "unavailable", text = "Learn a profession to begin tracking." }
    end

    local route = self:GetGuideRoute(profession)
    if not route then
        return {
            status = "route-needed",
            text = "No bundled route is available for this profession yet.",
            profession = profession,
        }
    end

    if route == WP.RouteData.fishingcooking then
        route.skills = route.skills or {}
        route.skills.Fishing = self.professions.Fishing or route.skills.Fishing or { skill=0, maxSkill=300 }
        route.skills.Cooking = self.professions.Cooking or route.skills.Cooking or { skill=0, maxSkill=300 }
        local fishingSkill = tonumber(route.skills.Fishing.skill) or 0
        local cookingSkill = tonumber(route.skills.Cooking.skill) or 0
        local activeBySkill = {}
        for index, step in ipairs(route.steps or {}) do
            local current = step.skill == "Fishing" and fishingSkill or cookingSkill
            if current < (tonumber(step.target) or 0) and not activeBySkill[step.skill] then
                local choices, mapRoutes = step.choices or {}, step.mapRoutes or {}
                if #choices == 0 and step.skill == "Fishing" then for zoneName in pairs(mapRoutes) do choices[#choices + 1] = zoneName end; table.sort(choices) end
                if step.skill == "Fishing" and WP.ZygorGatheringIndex and WP.ZygorGatheringIndex.fishing then
                    local routeSet = {}
                    for _, farm in ipairs(WP.ZygorGatheringIndex.fishing) do
                        local zoneName = farm.zone
                        if not mapRoutes[zoneName] then
                            mapRoutes[zoneName] = { mapID=farm.mapID, points=farm.points }
                            routeSet[zoneName] = true
                        end
                    end
                    for zoneName in pairs(routeSet) do choices[#choices + 1] = zoneName end
                end
                local savedZones = self.db and self.db.settings and self.db.settings.guideZones
                local savedZone = type(savedZones) == "table" and savedZones[zoneChoiceKey(profession, index)]
                local selectedZone = savedZone and mapRoutes[savedZone] and savedZone
                if not selectedZone then
                    local visibleMap = WorldMapFrame and type(WorldMapFrame.GetMapID) == "function" and WorldMapFrame:GetMapID()
                    if visibleMap then
                        for zoneName, mapRoute in pairs(mapRoutes) do if mapRoute.mapID == visibleMap then selectedZone = zoneName; break end end
                    end
                end
                if not selectedZone then
                    local ok, currentMap = C_Map and C_Map.GetBestMapForUnit and pcall(C_Map.GetBestMapForUnit, "player")
                    if ok and currentMap then
                        for zoneName, mapRoute in pairs(mapRoutes) do if mapRoute.mapID == currentMap then selectedZone = zoneName; break end end
                    end
                end
                if not selectedZone then
                    for _, candidate in ipairs(choices) do if mapRoutes[candidate] then selectedZone = candidate; break end end
                end
                selectedZone = selectedZone or step.zone
                local selectedRoute = mapRoutes[selectedZone]
                local firstPoint = selectedRoute and selectedRoute.points and selectedRoute.points[1]
                local task = {
                    status="active", route=route, profession=profession, stepIndex=index,
                    skillName=step.skill,
                    title=step.title, zone=selectedZone, focus=step.focus, target=step.target,
                    instructions=step.instructions, skill=current, maxSkill=300,
                    sourceStatus=route.sourceStatus, step=step, mapID=selectedRoute and selectedRoute.mapID or step.mapID,
                    routePoints=selectedRoute and selectedRoute.points, x=firstPoint and firstPoint[1] or step.x,
                    y=firstPoint and firstPoint[2] or step.y, choices=choices, selectedZone=selectedZone,
                    routeNote=route.routeNote,
                }
                activeBySkill[step.skill] = task
            end
        end
        local firstTask = activeBySkill.Fishing or activeBySkill.Cooking
        if firstTask then
            firstTask.activeTasks = activeBySkill
            firstTask.combinedProgress = string.format("Fishing %d/300 | Cooking %d/300", fishingSkill, cookingSkill)
            return firstTask
        end
        return { status="complete", route=route, profession=profession, title="Fishing + Cooking complete", target=300, skill=math.min(fishingSkill,cookingSkill), maxSkill=300, combinedProgress=string.format("Fishing %d/300 | Cooking %d/300", fishingSkill, cookingSkill) }
    end

    local skill = tonumber(profession.skill) or 0
    local maxSkill = tonumber(profession.maxSkill) or 0
    if route.name == "Fishing" then
        route.steps = route.steps or {}
        for index, step in ipairs(route.steps) do
            if skill < step.target then
                local choices, mapRoutes = step.choices or {}, step.mapRoutes or {}
                local selectedZone = choices[1] or step.zone
                local visible = WorldMapFrame and type(WorldMapFrame.GetMapID) == "function" and WorldMapFrame:GetMapID()
                local mapFound
                if visible then for zoneName, routeData in pairs(mapRoutes) do if routeData.mapID == visible then selectedZone = zoneName; mapFound = true; break end end end
                local onMapOK, onMap = C_Map and C_Map.GetBestMapForUnit and pcall(C_Map.GetBestMapForUnit, "player")
                if not mapFound and onMapOK and onMap then for zoneName, routeData in pairs(mapRoutes) do if routeData.mapID == onMap then selectedZone = zoneName; break end end end
                local saved = self.db and self.db.settings and self.db.settings.guideZones
                local savedZone = type(saved) == "table" and saved[zoneChoiceKey(profession, index)]
                if savedZone and mapRoutes[savedZone] then selectedZone = savedZone end
                local selected = mapRoutes[selectedZone]
                local first = selected and selected.points and selected.points[1]
                return { status="active", route=route, profession=profession, stepIndex=index, title=step.title,
                    zone=selectedZone, focus=step.focus, target=step.target, instructions=step.instructions,
                    skill=skill, maxSkill=maxSkill, choices=choices, selectedZone=selectedZone,
                    mapID=selected and selected.mapID or step.mapID, routePoints=selected and selected.points,
                    x=first and first[1] or step.x, y=first and first[2] or step.y, step=step,
                    routeNote=route.routeNote, sourceStatus=route.sourceStatus }
            end
        end
    end
    if route.skills then
        local skillData = route.skills[profession.name]
        if type(skillData) == "table" then skill = tonumber(skillData.skill) or skill; maxSkill = tonumber(skillData.maxSkill) or maxSkill end
    end

    for _, gate in ipairs(route.rankGates or {}) do
        if skill >= gate.skill and maxSkill > 0 and maxSkill <= gate.cap then
            local trainer = route.trainer or {}
            return {
                status = "trainer",
                route = route,
                profession = profession,
                skill = skill,
                maxSkill = maxSkill,
                title = gate.title or ("Train " .. gate.rank .. " " .. (route.name or "profession")),
                zone = gate.zone or trainer.zone or ("A " .. (route.name or "profession") .. " trainer"),
                mapID = gate.mapID or trainer.mapID,
                x = gate.x or trainer.x,
                y = gate.y or trainer.y,
                target = gate.cap,
                instructions = gate.note or trainer.note or ("Train " .. gate.rank .. " before continuing."),
            }
        end
    end

    for index, step in ipairs(route.steps or {}) do
        if skill < step.target then
            local chosenMap, chosenX, chosenY, chosenPoints, chosenZone = step.mapID, step.x, step.y, nil, step.zone
            local defaultRoute
            local choices = step.choices or {}
            local savedZones = self.db and self.db.settings and self.db.settings.guideZones
            local savedZone = type(savedZones) == "table" and savedZones[zoneChoiceKey(profession, index)]
            if savedZone then
                local valid = false
                for _, name in ipairs(choices) do if name == savedZone then valid = true; break end end
                if valid then
                    chosenZone = savedZone
                    local alternative = step.mapRoutes and step.mapRoutes[savedZone]
                    if alternative then
                        chosenMap, chosenPoints = alternative.mapID, alternative.points
                    else
                        chosenMap = ZONE_MAP_IDS[savedZone] or (findFarmRoute(route, savedZone, skill) or {}).mapID or chosenMap
                        local farm = findFarmRoute(route, savedZone, skill)
                        if farm then chosenPoints = farm.points end
                    end
                    local first = chosenPoints and chosenPoints[1]
                    if first then chosenX, chosenY = first[1], first[2] end
                end
            end
            for mapName, mapRoute in pairs(step.mapRoutes or {}) do
                if not defaultRoute then defaultRoute={name=mapName,data=mapRoute} end
                local visibleMap = WorldMapFrame and type(WorldMapFrame.GetMapID) == "function" and WorldMapFrame:GetMapID()
                if not savedZone and visibleMap and visibleMap == mapRoute.mapID then defaultRoute={name=mapName,data=mapRoute};break end
                local ok, currentMap = C_Map and C_Map.GetBestMapForUnit and pcall(C_Map.GetBestMapForUnit, "player")
                if not savedZone and ok and currentMap == mapRoute.mapID then defaultRoute={name=mapName,data=mapRoute};break end
            end
            if not savedZone and defaultRoute then chosenMap=defaultRoute.data.mapID;chosenPoints=defaultRoute.data.points;chosenZone=defaultRoute.name;local first=chosenPoints and chosenPoints[1];if first then chosenX,chosenY=first[1],first[2] end end
            if chosenZone and step.mapRoutes and step.mapRoutes[chosenZone] then
                local selectedRoute = step.mapRoutes[chosenZone]
                chosenMap, chosenPoints = selectedRoute.mapID, selectedRoute.points
                local first = chosenPoints and chosenPoints[1]
                if first then chosenX, chosenY = first[1], first[2] end
            end
            if chosenZone and not chosenPoints then
                local farm = findFarmRoute(route, chosenZone, skill)
                if farm then chosenMap, chosenPoints = farm.mapID, farm.points end
            end
            if chosenMap and not chosenPoints and chosenX and chosenY then
                chosenPoints = { { chosenX, chosenY } }
            end
            return {
                status = "active",
                route = route,
                profession = profession,
                skill = skill,
                maxSkill = maxSkill,
                stepIndex = index,
                title = step.title,
                zone = chosenZone,
                mapID = chosenMap,
                x = chosenX,
                y = chosenY,
                routePoints = chosenPoints,
                choices = choices,
                selectedZone = chosenZone,
                herbs = step.herbs,
                focus = step.focus or step.herbs,
                target = step.target,
                instructions = step.instructions,
                routeNote = route.routeNote,
                sourceStatus = step.sourceStatus or route.sourceStatus,
                step = step,
            }
        end
    end

    return {
        status = "complete",
        route = route,
        profession = profession,
        skill = skill,
        maxSkill = maxSkill,
        title = route.name .. " complete",
        zone = "300",
        target = route.maxSkill,
        instructions = "This bundled route is complete.",
    }
end

function WP:GetGuideSteps(profession)
    local route = self:GetGuideRoute(profession)
    if not route then return {} end
    local skill = tonumber(type(profession) == "table" and profession.skill) or 0
    if route.skills and type(profession) == "table" and type(route.skills[profession.name]) == "table" then
        skill = tonumber(route.skills[profession.name].skill) or skill
    end
    local currentBySkill = {}
    local rows = {}
    for i, step in ipairs(route.steps or {}) do
        local skillName = step.skill
        local stepSkill = skill
        if skillName then
            local live = self.professions and self.professions[skillName]
            local recorded = route.skills and route.skills[skillName]
            stepSkill = tonumber(live and live.skill) or tonumber(recorded and recorded.skill) or 0
        end
        local complete = stepSkill >= (tonumber(step.target) or 0)
        local key = skillName or route.name
        local current = not complete and not currentBySkill[key]
        if current then currentBySkill[key] = true end
        rows[#rows + 1] = { index = i, current = current,
            complete = complete, skill = skillName, skillValue = stepSkill, title = step.title,
            target = step.target, zone = step.zone, focus = step.focus or step.herbs,
            instructions = step.instructions, choices = step.choices,
            recipeOptions = step.recipeOptions, estimate = step.estimate,
            confidence = step.sourceStatus, carryForward = step.carryForward }
    end
    return rows
end

function WP:FormatGuideRoute(profession)
    local route = self:GetGuideRoute(profession)
    if not route then return "No guide is bundled for this profession." end
    local skill = tonumber(type(profession) == "table" and profession.skill) or 0
    if route.skills and type(profession) == "table" and type(route.skills[profession.name]) == "table" then
        skill = tonumber(route.skills[profession.name].skill) or skill
    end
    local lines
    if normalizeProfession(route.name) == "fishingcooking" then
        local fishing = (self.professions and self.professions.Fishing) or route.skills.Fishing or {}
        local cooking = (self.professions and self.professions.Cooking) or route.skills.Cooking or {}
        lines = { route.name .. " guide | Fishing " .. tostring(fishing.skill or 0) .. "/" .. tostring(fishing.maxSkill or 300)
            .. " | Cooking " .. tostring(cooking.skill or 0) .. "/" .. tostring(cooking.maxSkill or 300) }
    else
        lines = { route.name .. " guide | skill " .. skill .. "/" .. (route.maxSkill or 300) }
    end
    for _, row in ipairs(self:GetGuideSteps(profession)) do
        local marker = row.complete and "[x] " or (row.current and "> " or "[ ] ")
        lines[#lines + 1] = marker .. (row.skill and (row.skill .. ": ") or "") .. (row.title or "Guide step") .. (row.zone and (" - " .. row.zone) or "")
        if row.skill then lines[#lines + 1] = "    Skill " .. tostring(row.skillValue or 0) .. " -> " .. tostring(row.target or 300) end
        if row.focus and row.focus ~= "" then lines[#lines + 1] = "    Focus: " .. row.focus end
        if row.instructions and row.instructions ~= "" then lines[#lines + 1] = "    " .. row.instructions end
        if row.carryForward and row.carryForward ~= "" then lines[#lines + 1] = "    Carry forward: " .. row.carryForward end
        if row.choices and #row.choices > 0 then lines[#lines + 1] = "    Options: " .. table.concat(row.choices, " / ") end
        if row.confidence and row.confidence ~= "" then lines[#lines + 1] = "    Data: " .. row.confidence end
    end
    if route.routeNote then lines[#lines + 1] = "Note: " .. route.routeNote end
    lines[#lines + 1] = "Guide data: bundled profession guide"
    lines[#lines + 1] = "Confidence: " .. (route.sourceStatus or "Guide-derived; confirm in game")
    return table.concat(lines, "\n")
end

function WP:FormatCombinedGuideRoute(route)
    if not route or not route.skills then return "No combined guide is bundled." end
    local fishing = route.skills.Fishing or {}
    local cooking = route.skills.Cooking or {}
    local lines = { "Fishing + Cooking | Fishing " .. tostring(fishing.skill or 0) .. "/" .. tostring(fishing.maxSkill or 300)
        .. " | Cooking " .. tostring(cooking.skill or 0) .. "/" .. tostring(cooking.maxSkill or 300) }
    for _, step in ipairs(route.steps or {}) do
        local data = route.skills[step.skill] or {}
        local skill = tonumber(data.skill) or 0
        local done = skill >= (tonumber(step.target) or 0)
        local current = not done and skill >= (tonumber(step.from) or 0)
        local marker = done and "[x] " or (current and "> " or "[ ] ")
        lines[#lines + 1] = marker .. (step.skill or "Guide") .. " " .. tostring(step.from or 0) .. "-" .. tostring(step.target or 300)
            .. (step.zone and (" - " .. step.zone) or "")
        if step.focus then lines[#lines + 1] = "    Focus: " .. step.focus end
        if step.instructions then lines[#lines + 1] = "    " .. step.instructions end
    end
    lines[#lines + 1] = "Guide data: bundled profession guide"
    lines[#lines + 1] = "Confidence: " .. (route.sourceStatus or "Guide-derived; confirm in game")
    return table.concat(lines, "\n")
end

function WP:GetCurrentGuideState()
    local selectedName = self.selectedProfession
    local profession = selectedName and self.professions[selectedName]
    if not profession and normalizeProfession(selectedName) == "fishingcooking" then
        profession = { name = "Fishing + Cooking", skill = 0, maxSkill = 300 }
    end
    if not profession then return self:GetGuideState(nil) end
    local state = self:GetGuideState(profession)
    local key = normalizeProfession(profession.name)
    local selection
    if self.selectedGatheringProfession == key then
        selection = self.selectedGatheringRoute
    elseif self.db and self.db.settings and self.db.settings.gatheringRoutes then
        selection = self.db.settings.gatheringRoutes[key]
    end
    if selection then
        if state and state.status == "active" then
            local first = selection.points and selection.points[1]
            state.zone = selection.zone or state.zone
            state.mapID = selection.mapID or state.mapID
            state.routePoints = selection.points or state.routePoints
            state.x = first and first[1] or state.x
            state.y = first and first[2] or state.y
            state.selectedGatheringRoute = selection
            state.title = selection.item or selection.bracket or state.title
            state.target = selection.skill or selection.target or state.target
        end
    end
    return state
end

