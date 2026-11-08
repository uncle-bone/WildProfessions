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

    local skill = tonumber(profession.skill) or 0
    local maxSkill = tonumber(profession.maxSkill) or 0

    for _, gate in ipairs(route.rankGates or {}) do
        if skill >= gate.skill and maxSkill > 0 and maxSkill <= gate.cap then
            local trainer = route.trainer or {}
            return {
                status = "trainer",
                route = route,
                profession = profession,
                skill = skill,
                maxSkill = maxSkill,
                title = "Train " .. gate.rank .. " Herbalism",
                zone = trainer.zone or "An Herbalism trainer",
                mapID = trainer.mapID,
                x = trainer.x,
                y = trainer.y,
                target = gate.cap + 75,
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
                target = step.target,
                instructions = step.instructions,
                routeNote = route.routeNote,
                sourceStatus = route.sourceStatus,
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

function WP:GetCurrentGuideState()
    local profession = self.selectedProfession and self.professions[self.selectedProfession]
    return self:GetGuideState(profession)
end
