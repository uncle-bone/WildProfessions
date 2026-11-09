local _, WP = ...
WP = _G.WildProfessions or WP

WP.Planner = {}

local function normalizeName(value)
    return type(value) == "string" and value:lower():gsub("[^%a]", "") or ""
end

local function getEngineProfession(name)
    local public = _G.WildProfessionsPlannerAPI
    local api = type(public) == "table" and public.API
    if type(api) ~= "table" or type(api.Professions) ~= "function" then return nil end
    local ok, entries = pcall(api.Professions)
    if not ok or type(entries) ~= "table" then return nil end
    local wanted = normalizeName(name)
    for _, entry in ipairs(entries) do
        if normalizeName(entry.name) == wanted then return entry end
    end
end

local function itemName(itemID)
    if C_Item and type(C_Item.GetItemNameByID) == "function" then
        local ok, name = pcall(C_Item.GetItemNameByID, itemID)
        if ok and type(name) == "string" then return name end
    end
    if type(GetItemInfo) == "function" then
        local ok, name = pcall(GetItemInfo, itemID)
        if ok and type(name) == "string" then return name end
    end
    return "Item " .. tostring(itemID)
end

function WP.Planner.GetStatus(profession)
    if not profession then
        return { status = "unavailable", text = "Learn a profession to begin tracking." }
    end
    local state
    if profession.name == WP.selectedProfession and WP.professions and WP.professions[profession.name] then
        state = WP:GetCurrentGuideState()
    else
        state = WP:GetGuideState(profession)
    end
    if not state then
        return { status = "route-needed", text = "No bundled route is available for this profession yet." }
    end
    if state.status == "route-needed" then
        return {
            status = state.status,
            text = state.text,
            profession = profession.name,
        }
    end
    local result = {
        status = state.status,
        text = state.instructions or "",
        title = state.title,
        zone = state.zone,
        target = state.target,
        skill = state.skill,
        maxSkill = state.maxSkill,
        herbs = state.herbs,
        routeNote = state.routeNote,
        sourceStatus = state.sourceStatus,
        route = state.route,
        focus = state.focus,
        combinedProgress = state.combinedProgress,
        activeTasks = state.activeTasks,
        mapID = state.mapID,
        routePoints = state.routePoints,
        choices = state.choices,
        selectedZone = state.selectedZone,
        step = state.step,
    }
    return result
end

function WP.Planner.FormatEngineSteps(status, limit)
    local lines = {}
    local steps = status and status.engineSteps or {}
    if #steps > 0 then
        lines[#lines + 1] = "|cff67d5a3NEXT CRAFTING STEPS|r"
        for index = 1, math.min(#steps, limit or 3) do
            local step = steps[index]
            local text = step.text or step.kind or "Plan step"
            if step.detail and step.detail ~= "" then text = text .. " — " .. step.detail end
            lines[#lines + 1] = "- " .. text
        end
    end
    return table.concat(lines, "\n")
end

function WP.Planner.FormatEngineReagents(status, limit)
    local lines = {}
    local reagents = status and status.engineReagents or {}
    if #reagents > 0 then
        lines[#lines + 1] = "|cff67d5a3REAGENTS FOR THE PLAN|r"
        local shown = 0
        for _, reagent in ipairs(reagents) do
            if shown >= (limit or 5) then break end
            shown = shown + 1
            local have = tonumber(reagent.have) or 0
            local need = tonumber(reagent.need) or 0
            lines[#lines + 1] = string.format("%d/%d %s", math.min(have, need), need, itemName(reagent.itemID))
        end
        if #reagents > shown then lines[#lines + 1] = string.format("and %d more materials", #reagents - shown) end
    end
    return table.concat(lines, "\n")
end

function WP.Planner.GetGatheringChoices(profession)
    local route = WP:GetGuideRoute(profession)
    local result, seen = {}, {}
    if not route then return result end
    local currentSkill = tonumber(type(profession) == "table" and profession.skill) or 0
    local routeKey = normalizeName(route.name or (type(profession) == "table" and profession.name))
    local indexedKey = routeKey == "fishingcooking" and "fishing" or routeKey
    local indexed = WP.ZygorGatheringIndex and WP.ZygorGatheringIndex[indexedKey]
    local currentStep = WP:GetGuideState(profession)
    local currentChoices = currentStep and currentStep.choices or {}
    local combinedSkill = currentStep and currentStep.skillName and tonumber(currentStep.skill) or nil
    if combinedSkill then currentSkill = combinedSkill end
    if routeKey == "fishingcooking" then
        local fishingTask = currentStep and currentStep.activeTasks and currentStep.activeTasks.Fishing
        currentChoices = fishingTask and fishingTask.choices or currentChoices
        if fishingTask then currentStep = fishingTask; currentSkill = tonumber(fishingTask.skill) or 0 end
    end
    for _, zoneName in ipairs(currentChoices) do
        local found
        for _, step in ipairs(route.steps or {}) do
            if step.choices then
                for _, choice in ipairs(step.choices) do
                    if choice == zoneName then
                        local mapRoute = step.mapRoutes and step.mapRoutes[zoneName]
                        if mapRoute then found = { zone = zoneName, mapID = mapRoute.mapID, points = mapRoute.points, bracket = step.title, target = step.target } end
                        break
                    end
                end
            end
            if found then break end
        end
        if found then
            local key = found.zone .. ":" .. tostring(found.mapID)
            seen[key] = true
            result[#result + 1] = found
        end
    end
    for _, step in ipairs(route.steps or {}) do
        local eligibleBracket = currentSkill < (tonumber(step.target) or 0)
        if eligibleBracket then
            for zoneName, mapRoute in pairs(step.mapRoutes or {}) do
                local key = zoneName .. ":" .. tostring(mapRoute.mapID)
                if not seen[key] then
                    seen[key] = true
                    result[#result + 1] = { zone = zoneName, mapID = mapRoute.mapID, points = mapRoute.points, bracket = step.title, target = step.target }
                end
            end
        end
    end
    for _, farm in ipairs(route.farmRoutes or {}) do
        if farm.mapID and farm.zone and farm.points then
            local key = farm.zone .. ":" .. tostring(farm.mapID)
            if not seen[key] then
                seen[key] = true
                local threshold = tonumber(farm.skill) or 0
                local bracket = farm.name or "Gathering route"
                if threshold > currentSkill then bracket = bracket .. " - future skill " .. threshold end
                result[#result + 1] = { zone = farm.zone, mapID = farm.mapID, points = farm.points, bracket = bracket, target = threshold, faction = farm.faction, item = farm.item, available = threshold <= currentSkill }
            end
        end
    end
    for _, farm in ipairs(indexed or {}) do
        if farm.mapID and farm.zone and farm.points then
            local key = farm.zone .. ":" .. tostring(farm.mapID) .. ":" .. tostring(farm.skill)
            if not seen[key] then
                seen[key] = true
                local threshold = tonumber(farm.skill) or 0
                local bracket = string.format("%s (skill %d+)", farm.name or "Gathering", threshold)
                if threshold > currentSkill then bracket = bracket .. " - future" end
                result[#result + 1] = { zone=farm.zone, mapID=farm.mapID, points=farm.points, bracket=bracket, target=threshold, faction=farm.faction, item=farm.name, available=threshold <= currentSkill }
            end
        end
    end
    table.sort(result, function(a, b)
        if a.zone == b.zone then return (tonumber(a.target) or 0) < (tonumber(b.target) or 0) end
        return a.zone < b.zone
    end)
    return result
end

function WP.Planner.IsGatheringProfession(name)
    local key = normalizeName(name)
    return key == "herbalism" or key == "mining" or key == "skinning" or key == "fishing"
end

function WP.Planner.FormatAllEngineReagents(professionName, limit)
    local engine = getEngineProfession(professionName)
    local lines, reagents = {}, engine and engine.reagents or {}
    if #reagents > 0 then
        lines[#lines + 1] = "|cff67d5a3SKILLUP REAGENT CHECKLIST|r"
        local shown = 0
        for _, reagent in ipairs(reagents) do
            if shown >= (limit or 7) then break end
            shown = shown + 1
            local have, need = tonumber(reagent.have) or 0, tonumber(reagent.need) or 0
            local source = reagent.source == "gather" and " (gather)" or (reagent.source == "vendor" and " (vendor)" or "")
            lines[#lines + 1] = string.format("%d/%d %s%s", math.min(have, need), need, itemName(reagent.itemID), source)
        end
        if #reagents > shown then lines[#lines + 1] = string.format("and %d more reagents", #reagents - shown) end
    end
    return table.concat(lines, "\n")
end

function WP.Planner.GetEngineStatus(professionName)
    local engine = getEngineProfession(professionName)
    if not engine then return nil end
    return {
        title = engine.title,
        engineSteps = engine.steps or {},
        engineReagents = engine.reagents or {},
        engineRecipes = engine.recipes or {},
        engine = engine,
    }
end

function WP.Planner.FormatCombinedTasks(status)
    local tasks = status and status.activeTasks
    if not tasks then return "" end
    local lines = { "|cff67d5a3CURRENT FISHING + COOKING TASKS|r" }
    for _, key in ipairs({ "Fishing", "Cooking" }) do
        local task = tasks[key]
        if task then
            local text = string.format("%s: %s (skill %d -> %d)", key, task.title or task.zone or "current section", task.skill or 0, task.target or 300)
            if key == "Fishing" and task.zone then text = text .. " | Route: " .. task.zone end
            if key == "Cooking" then
                text = text .. " | Cook the fish already caught before buying more ingredients."
            end
            lines[#lines + 1] = text
        else
            lines[#lines + 1] = key .. ": guide complete"
        end
    end
    return table.concat(lines, "\n")
end

function WP.Planner.GetCombinedCookingMaterials(status)
    local task = status and status.activeTasks and status.activeTasks.Cooking
    if not task then return {} end
    return task.materials or {}
end

function WP.Planner.SetStrategy(strategy)
    local allowed = { fastest = true, cheapest = true, owned = true }
    if not allowed[strategy] then return false end
    WP:EnsureDatabase()
    WP.db.settings.strategy = strategy
    WP:UpdateDashboard()
    WP:UpdateTracker()
    return true
end

