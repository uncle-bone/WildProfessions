local _, WP = ...

WP.Planner = {}

function WP.Planner.GetStatus(profession)
    if not profession then
        return { status = "unavailable", text = "Learn a profession to begin tracking." }
    end
    local state = WP:GetGuideState(profession)
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
    return {
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
    }
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
