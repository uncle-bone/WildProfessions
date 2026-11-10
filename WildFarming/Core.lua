local addonName, WF = ...
_G.WildFarming = WF
WF.name = addonName or "WildFarming"
WF.version = "0.1.0-dev"

local defaults = { selectedCategory = "All", search = "", matchCharacter = true, route = nil, waypoint = 1, window = nil }
local function copyDefaults(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            copyDefaults(target[key], value)
        elseif target[key] == nil then target[key] = value end
    end
end
function WF:Print(message)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff8bcf73WildFarming:|r "..tostring(message)) end
end
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == WF.name then
        if type(WildFarmingDB) ~= "table" then WildFarmingDB = {} end
        copyDefaults(WildFarmingDB, defaults)
        WF.db = WildFarmingDB
    elseif event == "PLAYER_LOGIN" then
        if WF.Initialize then WF:Initialize() end
    end
end)
SLASH_WILDFARMING1 = "/wfarm"
SLASH_WILDFARMING2 = "/wfarming"
SlashCmdList.WILDFARMING = function(message)
    message = (message or ""):lower():match("^%s*(.-)%s*$")
    if message == "next" then if WF.NextWaypoint then WF:NextWaypoint() end
    elseif message == "stop" then if WF.StopRoute then WF:StopRoute() end
    elseif WF.Toggle then WF:Toggle()
    else WF:Print("Commands: /wfarm, /wfarm next, /wfarm stop") end
end
