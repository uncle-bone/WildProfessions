local _, WP = ...

local function normalizeProfession(name)
    if type(name) ~= "string" then return nil end
    return name:lower():gsub("[^%a]", "")
end

function WP:GetGuideRoute(profession)
    local name = type(profession) == "table" and profession.name or profession
    local key = normalizeProfession(name)
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
        for index, step in ipairs(route.steps or {}) do
            local current = route.skills[step.skill] or {}
            if (tonumber(current.skill) or 0) < (tonumber(step.target) or 0) then
                return { status="active", route=route, profession=profession, stepIndex=index, title=step.title, zone=step.zone, focus=step.focus, target=step.target, instructions=step.instructions, skill=tonumber(current.skill) or 0, maxSkill=tonumber(current.maxSkill) or 300, sourceStatus=route.sourceStatus, step=step, combinedProgress=string.format("Fishing %d/300 · Cooking %d/300", route.skills.Fishing.skill or 0, route.skills.Cooking.skill or 0) }
            end
        end
        return { status="complete", route=route, profession=profession, title="Fishing + Cooking complete", target=300, skill=300, maxSkill=300, combinedProgress=string.format("Fishing %d/300 · Cooking %d/300", route.skills.Fishing.skill or 0, route.skills.Cooking.skill or 0) }
    end
    local skill = tonumber(profession.skill) or 0
    local maxSkill = tonumber(profession.maxSkill) or 0
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
                title = "Train " .. gate.rank .. " " .. (route.name or "profession"),
                zone = trainer.zone or ("A " .. (route.name or "profession") .. " trainer"),
                mapID = trainer.mapID,
                x = trainer.x,
                y = trainer.y,
                target = gate.cap,
                instructions = trainer.note or ("Train " .. gate.rank .. " before continuing."),
            }
        end
    end

    for index, step in ipairs(route.steps or {}) do
        if skill < step.target then
            return {
                status = "active",
                route = route,
                profession = profession,
                skill = skill,
                maxSkill = maxSkill,
                stepIndex = index,
                title = step.title,
                zone = step.zone,
                mapID = step.mapID,
                x = step.x,
                y = step.y,
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
    local current = #route.steps
    for i, step in ipairs(route.steps or {}) do
        if skill < (tonumber(step.target) or 0) then current = i; break end
    end
    local rows = {}
    for i, step in ipairs(route.steps or {}) do
        rows[#rows + 1] = { index = i, current = i == current,
            complete = skill >= (tonumber(step.target) or 0), title = step.title,
            target = step.target, zone = step.zone, focus = step.focus or step.herbs,
            instructions = step.instructions, choices = step.choices,
            confidence = step.sourceStatus }
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
    local lines = { route.name .. " guide | skill " .. skill .. "/" .. (route.maxSkill or 300) }
    for _, row in ipairs(self:GetGuideSteps(profession)) do
        local marker = row.complete and "[x] " or (row.current and "> " or "[ ] ")
        lines[#lines + 1] = marker .. (row.title or "Guide step") .. (row.zone and (" - " .. row.zone) or "")
        if row.focus and row.focus ~= "" then lines[#lines + 1] = "    Focus: " .. row.focus end
        if row.instructions and row.instructions ~= "" then lines[#lines + 1] = "    " .. row.instructions end
        if row.choices and #row.choices > 0 then lines[#lines + 1] = "    Options: " .. table.concat(row.choices, " / ") end
        if row.confidence and row.confidence ~= "" then lines[#lines + 1] = "    Data: " .. row.confidence end
    end
    if route.routeNote then lines[#lines + 1] = "Note: " .. route.routeNote end
    lines[#lines + 1] = "Source: " .. (route.source or "WoW-Professions Forever")
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
    lines[#lines + 1] = "Source: " .. (route.source or "WoW-Professions Forever")
    lines[#lines + 1] = "Confidence: " .. (route.sourceStatus or "Guide-derived; confirm in game")
    return table.concat(lines, "\n")
end

function WP:GetCurrentGuideState()
    local profession = self.selectedProfession and self.professions[self.selectedProfession]
    if not profession and self.selectedProfession then
        for _, item in ipairs(self:GetProfessionList()) do if item.name == self.selectedProfession then profession = item; break end end
    end
    return self:GetGuideState(profession)
end

