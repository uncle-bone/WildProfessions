local _, WP = ...

WP.Planner = {}

function WP.Planner.GetStatus(profession)
    if not profession then
        return { status = "unavailable", text = "Learn a profession to begin tracking." }
    end
    return {
        status = "data-needed",
        text = "No verified route is loaded for this skill range. Scan live recipes or consult a cited route before recommending a craft.",
        strategy = WP.db and WP.db.settings and WP.db.settings.strategy or "owned",
        skill = profession.skill or 0,
        maxSkill = profession.maxSkill or 0,
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

