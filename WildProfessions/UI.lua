local _, WP = ...

local function createText(parent, font, size, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    if size and fs.SetFont then fs:SetFont("Fonts\\FRIZQT__.TTF", size, "") end
    if color then fs:SetTextColor(color[1], color[2], color[3]) end
    return fs
end

local function makeButton(parent, text, width, height, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function savePoint(frame, key)
    local point, _, relativePoint, x, y = frame:GetPoint(1)
    WP.db.settings[key] = { point = point, relativePoint = relativePoint, x = x, y = y }
end

local function restorePoint(frame, key, defaultPoint, x, y)
    local p = WP.db.settings[key]
    if type(p) == "table" and type(p.point) == "string" and type(p.relativePoint) == "string" then
        frame:SetPoint(p.point, UIParent, p.relativePoint, tonumber(p.x) or x, tonumber(p.y) or y)
    else
        frame:SetPoint(defaultPoint, UIParent, defaultPoint, x, y)
    end
end

function WP:CreateUI()
    if self.mainFrame then return end

    local main = CreateFrame("Frame", "WildProfessionsDashboard", UIParent, "BackdropTemplate")
    main:SetSize(560, 490)
    main:SetFrameStrata("DIALOG")
    main:SetClampedToScreen(true)
    main:SetMovable(true)
    main:EnableMouse(true)
    main:SetResizable(true)
    local canResize = type(main.SetResizeBounds) == "function"
    if canResize then
        canResize = pcall(main.SetResizeBounds, main, 460, 420)
    end
    if not canResize then main:SetResizable(false) end
    if main.SetBackdrop then
        main:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 24, insets = { left = 8, right = 8, top = 8, bottom = 8 } })
    end
    restorePoint(main, "dashboardPoint", "CENTER", 0, 0)
    local savedSize = self.db.settings.dashboardSize
    if type(savedSize) == "table" then main:SetSize(tonumber(savedSize.width) or 560, tonumber(savedSize.height) or 490) end

    local title = createText(main, "GameFontNormalLarge", 18, { 0.45, 0.82, 1 })
    title:SetPoint("TOPLEFT", 22, -18)
    title:SetText("WildProfessions")
    local version = createText(main, "GameFontDisableSmall", 11)
    version:SetPoint("TOPRIGHT", -40, -22)
    version:SetText("v" .. self.version .. "  |  TESTING")

    local close = CreateFrame("Button", nil, main, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    close:SetScript("OnClick", function() main:Hide() end)

    local drag = CreateFrame("Frame", nil, main)
    drag:SetPoint("TOPLEFT", 12, -8)
    drag:SetPoint("TOPRIGHT", -34, -8)
    drag:SetHeight(36)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function()
        if WP.dashboardDocked then
            local left, top = main:GetLeft(), main:GetTop()
            main:ClearAllPoints()
            if type(left) == "number" and type(top) == "number" then
                main:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
            end
            WP.dashboardDocked, WP.dashboardHost = false, nil
        end
        main:StartMoving()
    end)
    drag:SetScript("OnDragStop", function()
        main:StopMovingOrSizing()
        WP.dashboardDocked = false
        WP.dashboardHost = nil
        savePoint(main, "dashboardPoint")
        if WP.UpdateIntegration then WP:UpdateIntegration() end
    end)

    local left = createText(main, "GameFontNormal", 13)
    left:SetPoint("TOPLEFT", 24, -62)
    left:SetText("Your professions")
    local list = CreateFrame("Frame", nil, main)
    list:SetPoint("TOPLEFT", 22, -84)
    list:SetSize(190, 300)
    self.professionButtons = {}

    local divider = main:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.4, 0.55, 0.65, 0.5)
    divider:SetSize(1, 320)
    divider:SetPoint("TOPLEFT", 222, -72)

    local detailTitle = createText(main, "GameFontNormal", 13)
    detailTitle:SetPoint("TOPLEFT", 244, -62)
    detailTitle:SetText("Progress and planning")
    local progressBar = CreateFrame("StatusBar", nil, main)
    progressBar:SetSize(280, 12)
    progressBar:SetPoint("TOPLEFT", 244, -84)
    progressBar:SetMinMaxValues(0, 1)
    progressBar:SetValue(0)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0.2, 0.68, 0.9, 1)
    local progressBackground = progressBar:CreateTexture(nil, "BACKGROUND")
    progressBackground:SetAllPoints()
    progressBackground:SetColorTexture(0.08, 0.1, 0.13, 0.9)
    local detail = createText(main, "GameFontHighlight", 12)
    detail:SetPoint("TOPLEFT", 244, -108)
    detail:SetWidth(285)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("TOP")
    detail:SetText("Waiting for profession data.")

    local strategiesLabel = createText(main, "GameFontNormalSmall", 11)
    strategiesLabel:SetPoint("TOPLEFT", 244, -350)
    strategiesLabel:SetText("Planning preference (route data may be unavailable):")
    local strategyButtons = {}
    local strategyDefs = {
        { key = "fastest", text = "Fastest" },
        { key = "cheapest", text = "Cheapest" },
        { key = "owned", text = "Use owned" },
    }
    for i, def in ipairs(strategyDefs) do
        local b = makeButton(main, def.text, 88, 22, function() WP.Planner.SetStrategy(def.key) end)
        b:SetPoint("TOPLEFT", 244 + (i - 1) * 94, -370)
        strategyButtons[def.key] = b
    end

    local foot = createText(main, "GameFontDisableSmall", 10)
    foot:SetPoint("BOTTOMLEFT", 22, 20)
    foot:SetWidth(390)
    foot:SetJustifyH("LEFT")
    foot:SetText("Recipes, prices and skill-up odds are shown only when verified. Use /wp diagnostics for compatibility status.")

    local resize = CreateFrame("Button", nil, main)
    resize:SetSize(16, 16)
    resize:SetPoint("BOTTOMRIGHT", -8, 8)
    resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resize:SetScript("OnMouseDown", function() main:StartSizing("BOTTOMRIGHT") end)
    resize:SetScript("OnMouseUp", function()
        main:StopMovingOrSizing()
        local w, h = main:GetSize()
        WP.db.settings.dashboardSize = { width = w, height = h }
    end)
    if not canResize then resize:Hide() end

    local refresh = makeButton(main, "Refresh", 80, 22, function() WP:Refresh("manual") end)
    refresh:SetPoint("BOTTOMRIGHT", -32, 19)

    self.mainFrame, self.detailText, self.professionList, self.dashboardProgress = main, detail, list, progressBar
    self.strategyButtons = strategyButtons
    main:Hide()

    local tracker = CreateFrame("Frame", "WildProfessionsTracker", UIParent, "BackdropTemplate")
    tracker:SetSize(260, 112)
    tracker:SetFrameStrata("MEDIUM")
    tracker:SetClampedToScreen(true)
    tracker:SetMovable(true)
    tracker:EnableMouse(true)
    if tracker.SetBackdrop then
        tracker:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        tracker:SetBackdropColor(0.02, 0.03, 0.05, 0.9)
    end
    restorePoint(tracker, "trackerPoint", "TOPRIGHT", -80, -220)
    tracker:RegisterForDrag("LeftButton")
    tracker:SetScript("OnDragStart", function(f) if not WP.db.settings.trackerLocked then f:StartMoving() end end)
    tracker:SetScript("OnDragStop", function(f) f:StopMovingOrSizing(); savePoint(f, "trackerPoint") end)
    tracker.title = createText(tracker, "GameFontNormal", 12, { 0.45, 0.82, 1 })
    tracker.title:SetPoint("TOPLEFT", 10, -8)
    tracker.progress = createText(tracker, "GameFontHighlight", 11)
    tracker.progress:SetPoint("TOPLEFT", 10, -30)
    tracker.status = CreateFrame("StatusBar", nil, tracker)
    tracker.status:SetSize(238, 8)
    tracker.status:SetPoint("TOPLEFT", 10, -47)
    tracker.status:SetMinMaxValues(0, 1)
    tracker.status:SetValue(0)
    tracker.status:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    tracker.status:SetStatusBarColor(0.2, 0.68, 0.9, 1)
    local trackerBackground = tracker.status:CreateTexture(nil, "BACKGROUND")
    trackerBackground:SetAllPoints()
    trackerBackground:SetColorTexture(0.08, 0.1, 0.13, 0.9)
    tracker.activity = createText(tracker, "GameFontDisableSmall", 10)
    tracker.activity:SetPoint("TOPLEFT", 10, -64)
    tracker.activity:SetWidth(238)
    tracker.activity:SetJustifyH("LEFT")
    local trackerClose = CreateFrame("Button", nil, tracker, "UIPanelCloseButton")
    trackerClose:SetSize(22, 22)
    trackerClose:SetPoint("TOPRIGHT", -1, -1)
    trackerClose:SetScript("OnClick", function() tracker:Hide(); WP.db.settings.trackerVisible = false end)
    self.trackerFrame = tracker
    if self.db.settings.trackerVisible == false then tracker:Hide() end

    main:SetScript("OnSizeChanged", function(f, w, h)
        WP.db.settings.dashboardSize = { width = w, height = h }
    end)
end

function WP:UpdateDashboard()
    if not self.mainFrame then return end
    for _, b in ipairs(self.professionButtons or {}) do b:Hide() end
    wipe(self.professionButtons or {})
    local professions = self:GetProfessionList()
    if #professions == 0 then
        local empty = self.emptyProfessionText
        if not empty then
            empty = createText(self.professionList, "GameFontDisable", 11)
            empty:SetPoint("TOPLEFT", 4, -6)
            empty:SetWidth(175)
            empty:SetJustifyH("LEFT")
            self.emptyProfessionText = empty
        end
        empty:SetText("No profession data detected. Open the Forever profession window, then use Refresh.")
        empty:Show()
    else
        if self.emptyProfessionText then self.emptyProfessionText:Hide() end
        for i, profession in ipairs(professions) do
            local b = self.professionButtons[i]
            if not b then
                b = CreateFrame("Button", nil, self.professionList, "UIPanelButtonTemplate")
                b:SetSize(180, 26)
                self.professionButtons[i] = b
            end
            b:SetPoint("TOPLEFT", 0, -((i - 1) * 29))
            b:SetText(profession.name .. "  " .. tostring(profession.skill) .. "/" .. tostring(profession.maxSkill))
            b:SetScript("OnClick", function() WP.selectedProfession = profession.name; WP:UpdateDashboard(); WP:UpdateTracker() end)
            b:Show()
        end
    end
    local selected = self.selectedProfession and self.professions[self.selectedProfession]
    local status = WP.Planner.GetStatus(selected)
    local strategy = (self.db.settings.strategy or "owned")
    local strategyNames = { fastest = "Fastest Leveling", cheapest = "Cheapest", owned = "Use Materials I Already Own" }
    local strategyLabels = { fastest = "Fastest", cheapest = "Cheapest", owned = "Use owned" }
    for key, button in pairs(self.strategyButtons or {}) do
        button:SetText((key == strategy and "* " or "") .. (strategyLabels[key] or key))
    end
    if selected then
        local maxSkill = math.max(selected.maxSkill or 0, 1)
        self.dashboardProgress:SetMinMaxValues(0, maxSkill)
        self.dashboardProgress:SetValue(selected.skill or 0)
        self.detailText:SetText(string.format("|cffffffff%s|r\nSkill: %d / %d\n\nCurrent goal: continue %s progression.\n\nRecommendation: %s\n\nStrategy: %s\n\nRecipe database: not loaded\nMaterial totals and prices: unavailable\nSource verification: no route record", selected.name, selected.skill or 0, selected.maxSkill or 0, selected.name, status.text, strategyNames[strategy] or strategy))
    else
        self.dashboardProgress:SetMinMaxValues(0, 1)
        self.dashboardProgress:SetValue(0)
        self.detailText:SetText("No profession detected yet.\n\nOpen your profession window and press Refresh.\n\nDetected skill data will be saved per character.")
    end
end

function WP:UpdateTracker()
    if not self.trackerFrame then return end
    local p = self.selectedProfession and self.professions[self.selectedProfession]
    if not p then
        self.trackerFrame.title:SetText("WildProfessions")
        self.trackerFrame.progress:SetText("No profession detected")
        self.trackerFrame.status:SetMinMaxValues(0, 1)
        self.trackerFrame.status:SetValue(0)
        self.trackerFrame.activity:SetText("Open /wp for status and diagnostics.")
        return
    end
    local percent = (p.maxSkill or 0) > 0 and math.floor((p.skill or 0) * 100 / p.maxSkill) or 0
    self.trackerFrame.title:SetText(p.name)
    self.trackerFrame.progress:SetText(string.format("Skill %d / %d  (%d%%)", p.skill or 0, p.maxSkill or 0, percent))
    self.trackerFrame.status:SetMinMaxValues(0, math.max(p.maxSkill or 0, 1))
    self.trackerFrame.status:SetValue(p.skill or 0)
    self.trackerFrame.activity:SetText("Next route step: awaiting verified recipe data")
end

function WP:ToggleDashboard()
    if not self.mainFrame then self:CreateUI() end
    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
        self.dashboardDocked = false
        self.dashboardHost = nil
        if self.UpdateIntegration then self:UpdateIntegration() end
    else
        local host = self.GetProfessionHost and self:GetProfessionHost()
        if host then
            self:ShowIntegrated(host)
        else
            self.mainFrame:ClearAllPoints()
            restorePoint(self.mainFrame, "dashboardPoint", "CENTER", 0, 0)
            self.mainFrame:Show()
            self:Refresh("manual")
        end
    end
end

function WP:ShowIntegrated(host)
    if not self.mainFrame then self:CreateUI() end
    local frame = self.mainFrame
    frame:ClearAllPoints()
    local screenRight = UIParent and UIParent.GetRight and UIParent:GetRight()
    local hostRight = host and host.GetRight and host:GetRight()
    local hostLeft = host and host.GetLeft and host:GetLeft()
    local width = frame:GetWidth()
    if type(screenRight) == "number" and type(hostRight) == "number" and hostRight + width + 18 > screenRight then
        if type(hostLeft) == "number" and hostLeft - width - 18 >= 0 then
            frame:SetPoint("TOPRIGHT", host, "TOPLEFT", -10, -8)
        else
            frame:SetPoint("TOPLEFT", host, "BOTTOMLEFT", 0, -10)
        end
    else
        frame:SetPoint("TOPLEFT", host, "TOPRIGHT", 10, -8)
    end
    self.dashboardDocked = true
    self.dashboardHost = host
    frame:Show()
    self:Refresh("event")
end

function WP:HideDashboard()
    if self.mainFrame then self.mainFrame:Hide() end
end

function WP:ToggleTracker()
    if not self.trackerFrame then self:CreateUI() end
    if self.trackerFrame:IsShown() then
        self.trackerFrame:Hide()
        self.db.settings.trackerVisible = false
    else
        self.trackerFrame:Show()
        self.db.settings.trackerVisible = true
        self:UpdateTracker()
    end
end

function WP:ToggleLock()
    self:EnsureDatabase()
    self.db.settings.trackerLocked = not self.db.settings.trackerLocked
    self:Print("tracker " .. (self.db.settings.trackerLocked and "locked" or "unlocked") .. ".")
end

