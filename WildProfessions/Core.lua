local addonName, WP = ...
WP = WP or {}
_G.WildProfessions = WP
WP.name = addonName or "WildProfessions"
WP.version = "1.0.0"
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
    self:UpdateDashboard()
    self:UpdateTracker()
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
    self:Print("Recipe routes and prices are not bundled as verified data yet; no costs or skill-up chances are fabricated.")
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
        WP:InitializeIntegration()
        WP:ScheduleRefresh("login")
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
    if message == "refresh" then WP:Refresh("manual")
    elseif message == "tracker" then WP:ToggleTracker()
    elseif message == "lock" then WP:ToggleLock()
    elseif message == "diagnostics" then WP:Diagnostics()
    elseif message == "hide" then WP:HideDashboard()
    elseif message == "" or message == "show" then WP:ToggleDashboard()
    else
        WP:Print("Commands: /wp, /wp refresh, /wp tracker, /wp lock, /wp hide, /wp diagnostics")
    end
end

