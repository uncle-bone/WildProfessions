local _, WP = ...

local integrationEvents
local integrationUpdatePending = false

local function scheduleIntegrationUpdate()
    if integrationUpdatePending then return end
    integrationUpdatePending = true
    local function update()
        integrationUpdatePending = false
        WP:UpdateIntegration()
    end
    if C_Timer and C_Timer.After then C_Timer.After(0.1, update) else update() end
end

local function isShown(frame)
    if not frame or type(frame.IsShown) ~= "function" then return false end
    local ok, result = pcall(frame.IsShown, frame)
    return ok and result == true
end

local function safeAlpha(frame)
    if not frame or type(frame.GetAlpha) ~= "function" then return 1 end
    local ok, alpha = pcall(frame.GetAlpha, frame)
    if ok and type(alpha) == "number" then return alpha end
    return 1
end

local function addonLoaded(name)
    local fn = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    if type(fn) ~= "function" then return false end
    local ok, loaded = pcall(fn, name)
    return ok and loaded == true
end

function WP:GetProfessionHost()
    local naowh = _G.NaowhForeverProfessions
    if isShown(naowh) then return naowh, "NaowhForever" end

    local native = _G.ProfessionsFrame
    if isShown(native) and safeAlpha(native) > 0 then return native, "Forever Professions" end
    return nil
end

function WP:UpdateIntegration()
    if not self.mainFrame then return end
    local host, hostKind = self:GetProfessionHost()
    self.compat = self.compat or {}
    self.compat.hostKind = hostKind
    self.compat.naowhLoaded = addonLoaded("NaowhForever") or addonLoaded("NaowhForever_Professions")
    self.compat.ellesmereLoaded = addonLoaded("EllesmereUI") or addonLoaded("EllesmereUIQoL")

    if self.launcher then
        if host then
            self.launcher:ClearAllPoints()
            self.launcher:SetFrameStrata(host:GetFrameStrata() or "DIALOG")
            self.launcher:SetFrameLevel((host:GetFrameLevel() or 1) + 8)
            -- Separate UIParent sibling: the Blizzard frame is never reparented,
            -- resized, scaled, moved, or given a child by WildProfessions.
            self.launcher:SetPoint("TOPRIGHT", host, "TOPRIGHT", -34, -8)
            self.launcher:Show()
        else
            self.launcher:Hide()
        end
    end

    if self.dashboardDocked then
        if host then
            if host ~= self.dashboardHost then self:ShowIntegrated(host) end
        else
            self.mainFrame:Hide()
            self.dashboardDocked, self.dashboardHost = false, nil
        end
    end
    self:UpdateDashboard()
end

function WP:IntegrationAddonLoaded(name)
    if name == "NaowhForever" or name == "NaowhForever_Professions" or name == "EllesmereUI" or name == "EllesmereUIQoL" then
        self:UpdateIntegration()
    end
end

function WP:InitializeIntegration()
    if not self.mainFrame then return end
    if not self.launcher then
        local button = CreateFrame("Button", "WildProfessionsPaneLauncher", UIParent, "UIPanelButtonTemplate")
        button:SetSize(126, 24)
        button:SetText("WildProfessions")
        button:SetScript("OnClick", function() WP:ToggleIntegrated() end)
        button:SetScript("OnEnter", function(self)
            if GameTooltip then
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetText("WildProfessions planner")
                GameTooltip:AddLine("Opens beside the active profession pane.", 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        button:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
        self.launcher = button
    end

    if not integrationEvents then
        integrationEvents = CreateFrame("Frame")
        integrationEvents:RegisterEvent("TRADE_SKILL_SHOW")
        integrationEvents:RegisterEvent("TRADE_SKILL_CLOSE")
        integrationEvents:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
        integrationEvents:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED")
        integrationEvents:RegisterEvent("ADDON_LOADED")
        integrationEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
        integrationEvents:SetScript("OnEvent", function(_, event, arg1)
            if event == "ADDON_LOADED" then WP:IntegrationAddonLoaded(arg1) end
            if event == "TRADE_SKILL_SHOW" then WP:ScanOpenProfession() end
            scheduleIntegrationUpdate()
        end)
    end

    if EventRegistry and type(EventRegistry.RegisterCallback) == "function" and not self.eventRegistryBound then
        self.eventRegistryBound = true
        pcall(EventRegistry.RegisterCallback, EventRegistry, "ProfessionsFrame.Show", scheduleIntegrationUpdate, self)
        pcall(EventRegistry.RegisterCallback, EventRegistry, "ProfessionsFrame.Hide", scheduleIntegrationUpdate, self)
        pcall(EventRegistry.RegisterCallback, EventRegistry, "Professions.ProfessionSelected", function(_, info)
            if type(info) == "table" and type(info.professionName) == "string" then
                WP.selectedProfession = info.professionName
                WP:ScanOpenProfession()
                WP:UpdateDashboard()
                WP:UpdateTracker()
            end
            scheduleIntegrationUpdate()
        end, self)
    end
    self:UpdateIntegration()
end

function WP:ToggleIntegrated()
    local host = self:GetProfessionHost()
    if not host then
        self:Print("Open a profession pane first, or use /wp for the standalone dashboard.")
        return
    end
    if self.mainFrame and self.mainFrame:IsShown() and self.dashboardDocked then
        self.mainFrame:Hide()
        self.dashboardDocked, self.dashboardHost = false, nil
    else
        self:ShowIntegrated(host)
    end
end


