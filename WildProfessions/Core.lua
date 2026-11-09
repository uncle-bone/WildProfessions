local addonName, WP = ...
WP = WP or {}
_G.WildProfessions = WP
WP.name = addonName or "WildProfessions"
WP.version = "1.3.0-test.8-dev"
WP.professions = WP.professions or {}
WP.selectedProfession = nil
WP.refreshPending = false

local function safeString(value, fallback)
    if type(value) ~= "string" then return fallback end
    local ok, result = pcall(function() return value end)
    if ok and type(result) == "string" then return result end
    return fallback
end

function WP:Print(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff67d5ffWildProfessions:|r " .. tostring(message))
    end
end

local function safeCallString(fn, argument, fallback)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, argument)
    if ok and type(value) == "string" then return value end
    return fallback
end

function WP:CharacterKey()
    local name = safeCallString(UnitName, "player", "Unknown")
    local realm = safeCallString(GetRealmName, nil, "Unknown Realm")
    local guid = ""
    if UnitGUID then
        local ok, value = pcall(UnitGUID, "player")
        if ok then guid = safeString(value, "") end
    end
    return guid ~= "" and guid or (realm .. "-" .. name), name, realm
end

function WP:EnsureDatabase()
    if type(WildProfessionsDB) ~= "table" then WildProfessionsDB = {} end
    local db = WildProfessionsDB
    if type(db.version) ~= "number" then db.version = 1 end
    if type(db.characters) ~= "table" then db.characters = {} end
    if type(db.settings) ~= "table" then db.settings = {} end
    local key, name, realm = self:CharacterKey()
    if type(db.characters[key]) ~= "table" then db.characters[key] = {} end
    local char = db.characters[key]
    char.name, char.realm = name, realm
    if type(char.professions) ~= "table" then char.professions = {} end
    if type(char.history) ~= "table" then char.history = {} end
    if type(char.queue) ~= "table" then char.queue = {} end
    self.db, self.characterKey, self.character = db, key, char
    return char
end

function WP:Refresh(reason)
    self:EnsureDatabase()
    self:ScanProfessions()
    if self.selectedProfession and not self.professions[self.selectedProfession] then
        self.selectedProfession = nil
        for _, profession in ipairs(self:GetProfessionList()) do
            if not profession.guideOnly then self.selectedProfession = profession.name; break end
        end
    end
    self:UpdateDashboard()
    self:UpdateTracker()
    if self.UpdateGuideArrow then self:UpdateGuideArrow() end
    if reason == "manual" then self:Print("Profession data refreshed.") end
end

function WP:ScheduleRefresh(reason)
    if self.refreshPending then return end
    self.refreshPending = true
    local function run()
        WP.refreshPending = false
        WP:Refresh(reason)
    end
    if C_Timer and C_Timer.After then C_Timer.After(0.25, run) else run() end
end

function WP:Diagnostics()
    local toc
    if type(GetBuildInfo) == "function" then
        local ok, _, _, _, build = pcall(GetBuildInfo)
        if ok then toc = build end
    end
    local count = 0
    for _ in pairs(self.professions) do count = count + 1 end
    self:Print("version " .. self.version .. " | TOC " .. tostring(toc or "unknown") .. " | professions detected " .. count .. ".")
    local compat = self.compat or {}
    self:Print("pane: " .. tostring(compat.hostKind or "none") .. " | NaowhForever: " .. (compat.naowhLoaded and "detected" or "not detected") .. " | EllesmereUI: " .. (compat.ellesmereLoaded and "detected" or "not detected") .. ".")
    local routes = 0
    for _ in pairs(WP.RouteData or {}) do routes = routes + 1 end
    local gathering = 0
    for _, rows in pairs(WP.ZygorGatheringIndex or {}) do for _ in ipairs(rows) do gathering = gathering + 1 end end
    self:Print("Bundled guide routes: " .. routes .. " | indexed Zygor gathering/farming paths: " .. gathering .. ". Use /wp route to print the selected profession's full route. Source recommendations remain unverified until checked in game.")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
frame:RegisterEvent("TRADE_SKILL_SHOW")
frame:RegisterEvent("TRADE_SKILL_CLOSE")
frame:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED")
frame:RegisterEvent("TRADE_SKILL_NAME_UPDATE")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        WP:EnsureDatabase()
        WP:CreateUI()
        if WP.InitializeGuideArrow then WP:InitializeGuideArrow() end
        if WP.InitializeMinimapButton then WP:InitializeMinimapButton() end
        if WP.InitializeMapOverlay then WP:InitializeMapOverlay() end
        WP:InitializeIntegration()
        WP:ScheduleRefresh("login")
        if C_Timer and C_Timer.After then
            C_Timer.After(2, function()
                if WP.selectedProfession then
                    WP.professions[WP.selectedProfession] = WP.professions[WP.selectedProfession] or { name = WP.selectedProfession, skill = 0, maxSkill = 300 }
                    WP:UpdateDashboard()
                end
            end)
        end
    elseif event == "TRADE_SKILL_SHOW" then
        WP:ScanOpenProfession()
        WP:UpdateIntegration()
        WP:ScheduleRefresh("profession")
    elseif event == "TRADE_SKILL_CLOSE" then
        WP:UpdateIntegration()
        WP:ScheduleRefresh("event")
    elseif event == "TRADE_SKILL_LIST_UPDATE" then
        WP:ScanOpenProfession()
        WP:ScheduleRefresh("profession")
    else
        if event == "TRADE_SKILL_DATA_SOURCE_CHANGED" or event == "TRADE_SKILL_NAME_UPDATE" then WP:ScanOpenProfession() end
        if event == "ADDON_LOADED" and WP.IntegrationAddonLoaded then WP:IntegrationAddonLoaded(...) end
        WP:ScheduleRefresh("event")
    end
end)

SLASH_WILDPROFESSIONS1 = "/wp"
SLASH_WILDPROFESSIONS2 = "/wildprofessions"
SlashCmdList.WILDPROFESSIONS = function(message)
    message = (message or ""):lower():match("^%s*(.-)%s*$")
    if message == "" or message == "show" or message == "ui" or message == "guides" then WP:OpenMainWindow()
    elseif message == "refresh" then WP:Refresh("manual")
    elseif message == "tracker" then WP:ToggleTracker()
    elseif message == "guide" then WP:ToggleGuideArrow()
    elseif message == "lock" then WP:ToggleLock()
    elseif message == "diagnostics" then WP:Diagnostics()
    elseif message == "hide" then WP:HideDashboard()
    elseif message == "route" or message == "routes" then
        local state = WP:GetCurrentGuideState()
        if state and WP.FormatGuideRoute then
            for line in WP:FormatGuideRoute(state.profession):gmatch("[^" .. string.char(10) .. "]+") do WP:Print(line) end
        else WP:Print("Open a guide first, then use /wp route.") end
    elseif message == "zone" then WP:CycleGuideZone()
    elseif message == "shopping" or message == "shop" then WP:OpenShoppingList()
    elseif message == "settings" then
        if SlashCmdList.WILDPROFESSIONS_SKILLUP then SlashCmdList.WILDPROFESSIONS_SKILLUP("") end
    elseif message == "report" or message == "help" or message == "audit" or message == "trainers" or message == "leaderboard" or message == "stats" or message == "share" or message == "export" or message == "issue" or message == "bug" or message == "feature" or message == "unskip" then
        if SlashCmdList.WILDPROFESSIONS_SKILLUP then SlashCmdList.WILDPROFESSIONS_SKILLUP(message) end
    else
        WP:Print("Commands: /wp, /wp guides, /wp route, /wp zone, /wp shopping, /wp tracker, /wp settings, /wp refresh")
    end
end


