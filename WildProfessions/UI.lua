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
    button:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
    button:SetPushedTexture("Interface\\Buttons\\WHITE8X8")
    local normal=button:GetNormalTexture();if normal then normal:SetVertexColor(0.1,0.16,0.16,1) end
    local highlight=button:GetHighlightTexture();if highlight then highlight:SetVertexColor(0.25,0.78,0.45,0.35) end
    local fs=button:GetFontString();if fs then fs:SetTextColor(0.88,0.94,0.91) end
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
    main:SetSize(900, 600)
    main:SetFrameStrata("DIALOG")
    main:SetClampedToScreen(true)
    main:SetMovable(true)
    main:EnableMouse(true)
    main:SetResizable(true)
    if main.SetResizeBounds then pcall(main.SetResizeBounds, main, 760, 520) end
    if main.SetBackdrop then
        main:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, edgeSize = 14, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
        main:SetBackdropColor(0.035, 0.045, 0.06, 0.98)
        main:SetBackdropBorderColor(0.25, 0.34, 0.39, 1)
    end
    restorePoint(main, "dashboardPoint", "CENTER", 0, 0)
    local savedSize = self.db.settings.dashboardSize
    if type(savedSize) == "table" then main:SetSize(tonumber(savedSize.width) or 900, tonumber(savedSize.height) or 600) end

    local header = CreateFrame("Frame", nil, main, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 8, -8)
    header:SetPoint("TOPRIGHT", -8, -8)
    header:SetHeight(60)
    if header.SetBackdrop then
        header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        header:SetBackdropColor(0.055, 0.075, 0.09, 1)
    end
    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(0.25, 0.78, 0.45, 1)
    accent:SetHeight(2)
    accent:SetPoint("BOTTOMLEFT", 0, 0)
    accent:SetPoint("BOTTOMRIGHT", 0, 0)

    local logo = createText(header, "GameFontNormalLarge", 20, { 0.45, 0.9, 0.62 })
    logo:SetText("W")
    logo:SetPoint("LEFT", 18, 1)
    local title = createText(header, "GameFontNormalLarge", 17, { 0.93, 0.96, 0.98 })
    title:SetText("WILD PROFESSIONS")
    title:SetPoint("LEFT", logo, "RIGHT", 12, 5)
    local subtitle = createText(header, "GameFontDisableSmall", 10)
    subtitle:SetText("FOREVER PROFESSION GUIDES")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
    local version = createText(header, "GameFontDisableSmall", 10)
    version:SetText("v" .. self.version .. "  •  STANDALONE")
    version:SetPoint("RIGHT", -48, 0)

    local close = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    close:SetPoint("RIGHT", -4, 0)
    close:SetScript("OnClick", function() main:Hide() end)

    local drag = CreateFrame("Frame", nil, header)
    drag:SetPoint("TOPLEFT", 0, 0)
    drag:SetPoint("BOTTOMRIGHT", -38, 2)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function()
        if WP.dashboardDocked then
            local left, top = main:GetLeft(), main:GetTop()
            main:ClearAllPoints()
            if type(left) == "number" and type(top) == "number" then main:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top) end
            WP.dashboardDocked, WP.dashboardHost = false, nil
        end
        main:StartMoving()
    end)
    drag:SetScript("OnDragStop", function()
        main:StopMovingOrSizing()
        WP.dashboardDocked, WP.dashboardHost = false, nil
        savePoint(main, "dashboardPoint")
        if WP.UpdateIntegration then WP:UpdateIntegration() end
    end)

    local sidebar = CreateFrame("Frame", nil, main, "BackdropTemplate")
    sidebar:SetPoint("TOPLEFT", 16, -78)
    sidebar:SetPoint("BOTTOMLEFT", 16, 44)
    sidebar:SetWidth(235)
    if sidebar.SetBackdrop then
        sidebar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        sidebar:SetBackdropColor(0.055, 0.07, 0.085, 0.94)
        sidebar:SetBackdropBorderColor(0.12, 0.19, 0.21, 1)
    end
    local listHeading = createText(sidebar, "GameFontNormal", 12, { 0.45, 0.9, 0.62 })
    listHeading:SetText("GUIDE LIBRARY")
    listHeading:SetPoint("TOPLEFT", 14, -14)
    local listSub = createText(sidebar, "GameFontDisableSmall", 10)
    listSub:SetText("Choose a profession to view its route")
    listSub:SetPoint("TOPLEFT", 14, -34)

    local search = CreateFrame("EditBox", nil, sidebar, "InputBoxTemplate")
    search:SetSize(205, 24)
    search:SetPoint("TOPLEFT", 13, -56)
    search:SetAutoFocus(false)
    search:SetTextInsets(8, 6, 2, 2)
    search:SetText(self.db.settings.guideSearch or "")
    search:SetScript("OnTextChanged", function(box)
        WP.db.settings.guideSearch = box:GetText() or ""
        WP:UpdateDashboard()
    end)
    self.guideSearch = search

    local scroll = CreateFrame("ScrollFrame", nil, sidebar, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -88)
    scroll:SetPoint("BOTTOMRIGHT", -28, 12)
    local list = CreateFrame("Frame", nil, scroll)
    list:SetSize(190, 400)
    scroll:SetScrollChild(list)
    scroll:SetScript("OnMouseWheel", function(f, delta)
        local current = f:GetVerticalScroll()
        f:SetVerticalScroll(math.max(0, current - delta * 48))
    end)
    self.professionButtons = {}
    self.professionList, self.professionScroll = list, scroll

    local content = CreateFrame("Frame", nil, main)
    content:SetPoint("TOPLEFT", 270, -82)
    content:SetPoint("BOTTOMRIGHT", -20, 42)

    local eyebrow = createText(content, "GameFontNormalSmall", 10, { 0.45, 0.9, 0.62 })
    eyebrow:SetText("ACTIVE PROFESSION")
    eyebrow:SetPoint("TOPLEFT", 8, -4)
    local professionTitle = createText(content, "GameFontNormalLarge", 22, { 0.94, 0.97, 0.98 })
    professionTitle:SetText("Select a guide")
    professionTitle:SetPoint("TOPLEFT", 8, -22)
    self.professionTitle = professionTitle
    local skillLabel = createText(content, "GameFontHighlight", 12, { 0.75, 0.82, 0.86 })
    skillLabel:SetText("Skill progress")
    skillLabel:SetPoint("TOPRIGHT", -10, -28)
    self.skillLabel = skillLabel

    local progress = CreateFrame("StatusBar", nil, content)
    progress:SetSize(570, 14)
    progress:SetPoint("TOPLEFT", 8, -62)
    progress:SetMinMaxValues(0, 1)
    progress:SetValue(0)
    progress:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progress:SetStatusBarColor(0.24, 0.78, 0.46, 1)
    local progressBg = progress:CreateTexture(nil, "BACKGROUND")
    progressBg:SetAllPoints()
    progressBg:SetColorTexture(0.1, 0.14, 0.16, 1)
    self.dashboardProgress = progress

    local card = CreateFrame("Frame", nil, content, "BackdropTemplate")
    card:SetPoint("TOPLEFT", 0, -94)
    card:SetPoint("TOPRIGHT", 0, -94)
    card:SetHeight(246)
    if card.SetBackdrop then
        card:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        card:SetBackdropColor(0.06, 0.08, 0.095, 0.98)
        card:SetBackdropBorderColor(0.14, 0.22, 0.23, 1)
    end
    local cardAccent = card:CreateTexture(nil, "ARTWORK")
    cardAccent:SetColorTexture(0.25, 0.78, 0.45, 1)
    cardAccent:SetWidth(3)
    cardAccent:SetPoint("TOPLEFT", 0, 0)
    cardAccent:SetPoint("BOTTOMLEFT", 0, 0)
    local stepLabel = createText(card, "GameFontNormalSmall", 10, { 0.45, 0.9, 0.62 })
    stepLabel:SetText("CURRENT GUIDE STEP")
    stepLabel:SetPoint("TOPLEFT", 18, -16)
    local stepTitle = createText(card, "GameFontNormal", 16, { 0.96, 0.97, 0.98 })
    stepTitle:SetText("Waiting for guide data")
    stepTitle:SetPoint("TOPLEFT", 18, -38)
    stepTitle:SetWidth(535)
    stepTitle:SetJustifyH("LEFT")
    self.guideStepTitle = stepTitle
    local zone = createText(card, "GameFontHighlight", 12, { 0.9, 0.75, 0.38 })
    zone:SetText("Open a profession guide to begin.")
    zone:SetPoint("TOPLEFT", 18, -66)
    zone:SetWidth(535)
    zone:SetJustifyH("LEFT")
    self.guideZone = zone
    local detail = createText(card, "GameFontHighlight", 12, { 0.78, 0.84, 0.87 })
    detail:SetPoint("TOPLEFT", 18, -94)
    detail:SetWidth(535)
    detail:SetHeight(140)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("TOP")
    self.detailText = detail

    local prefLabel = createText(content, "GameFontNormalSmall", 10, { 0.45, 0.9, 0.62 })
    prefLabel:SetText("ROUTE PREFERENCE")
    prefLabel:SetPoint("TOPLEFT", 8, -356)
    local strategyButtons = {}
    local strategyDefs = {
        { key = "fastest", text = "Fastest" },
        { key = "cheapest", text = "Lowest cost" },
        { key = "owned", text = "Use my materials" },
    }
    for i, def in ipairs(strategyDefs) do
        local b = makeButton(content, def.text, 145, 26, function() WP.Planner.SetStrategy(def.key) end)
        b:SetPoint("TOPLEFT", 8 + (i - 1) * 153, -376)
        strategyButtons[def.key] = b
    end
    self.strategyButtons = strategyButtons

    local toolsLabel = createText(content, "GameFontNormalSmall", 10, { 0.45, 0.9, 0.62 })
    toolsLabel:SetText("GUIDE TOOLS")
    toolsLabel:SetPoint("TOPLEFT", 8, -418)
    local function toolButton(text, x, onClick)
        local b = makeButton(content, text, 135, 30, onClick)
        b:SetPoint("TOPLEFT", x, -438)
        return b
    end
    toolButton("Start Route Arrow", 8, function() if not WP.guideArrow then WP:InitializeGuideArrow() end; WP.db.settings.guideVisible = true; WP.guideArrow:Show(); WP:UpdateGuideArrow() end)
    toolButton("Show Map Route", 151, function() WP:ToggleMapRoutes() end)
    toolButton("Open Tracker", 294, function() WP:ToggleTracker() end)
    toolButton("Refresh Data", 437, function() WP:Refresh("manual") end)

    local footer = createText(content, "GameFontDisableSmall", 10)
    footer:SetPoint("BOTTOMLEFT", 8, 4)
    footer:SetWidth(520)
    footer:SetJustifyH("LEFT")
    footer:SetText("Guide steps are character-aware. Route points are approximate farming areas; use in-game tracking for live nodes.")
    self.dashboardFooter = footer

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

    self.mainFrame = main
    main:Hide()

    local tracker = CreateFrame("Frame", "WildProfessionsTracker", UIParent, "BackdropTemplate")
    tracker:SetSize(280, 156)
    tracker:SetFrameStrata("MEDIUM")
    tracker:SetClampedToScreen(true)
    tracker:SetMovable(true)
    tracker:EnableMouse(true)
    if tracker.SetBackdrop then
        tracker:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        tracker:SetBackdropColor(0.035, 0.045, 0.06, 0.96)
    end
    restorePoint(tracker, "trackerPoint", "TOPRIGHT", -80, -220)
    tracker:RegisterForDrag("LeftButton")
    tracker:SetScript("OnDragStart", function(f) if not WP.db.settings.trackerLocked then f:StartMoving() end end)
    tracker:SetScript("OnDragStop", function(f) f:StopMovingOrSizing(); savePoint(f, "trackerPoint") end)
    tracker.title = createText(tracker, "GameFontNormal", 13, { 0.45, 0.9, 0.62 })
    tracker.title:SetPoint("TOPLEFT", 12, -10)
    tracker.progress = createText(tracker, "GameFontHighlight", 11)
    tracker.progress:SetPoint("TOPLEFT", 12, -34)
    tracker.status = CreateFrame("StatusBar", nil, tracker)
    tracker.status:SetSize(252, 9)
    tracker.status:SetPoint("TOPLEFT", 12, -52)
    tracker.status:SetMinMaxValues(0, 1)
    tracker.status:SetValue(0)
    tracker.status:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    tracker.status:SetStatusBarColor(0.24, 0.78, 0.46, 1)
    local trackerBackground = tracker.status:CreateTexture(nil, "BACKGROUND")
    trackerBackground:SetAllPoints()
    trackerBackground:SetColorTexture(0.1, 0.14, 0.16, 1)
    tracker.activity = createText(tracker, "GameFontHighlightSmall", 10, { 0.78, 0.84, 0.87 })
    tracker.activity:SetPoint("TOPLEFT", 12, -70)
    tracker.activity:SetWidth(252)
    tracker.activity:SetHeight(70)
    tracker.activity:SetJustifyH("LEFT")
    tracker.activity:SetJustifyV("TOP")
    local trackerClose = CreateFrame("Button", nil, tracker, "UIPanelCloseButton")
    trackerClose:SetSize(22, 22)
    trackerClose:SetPoint("TOPRIGHT", -1, -1)
    trackerClose:SetScript("OnClick", function() tracker:Hide(); WP.db.settings.trackerVisible = false end)
    self.trackerFrame = tracker
    if self.db.settings.trackerVisible == false then tracker:Hide() end

    main:SetScript("OnSizeChanged", function(f, w, h) WP.db.settings.dashboardSize = { width = w, height = h } end)
end

function WP:UpdateDashboard()
    if not self.mainFrame then return end
    local professions = self:GetProfessionList()
    if not self.selectedProfession and #professions > 0 then
        for _, item in ipairs(professions) do if item.name == "Herbalism" then self.selectedProfession = item.name; break end end
        if not self.selectedProfession then self.selectedProfession = professions[1].name end
    end
    local query = (self.guideSearch and self.guideSearch:GetText() or ""):lower()
    local visible = 0
    for _, button in ipairs(self.professionButtons or {}) do button:Hide() end
    for _, profession in ipairs(professions) do
        if query == "" or profession.name:lower():find(query, 1, true) then
            visible = visible + 1
            local b = self.professionButtons[visible]
            if not b then
                b = CreateFrame("Button", nil, self.professionList, "BackdropTemplate")
                b:SetSize(190, 30)
                b.bg = b:CreateTexture(nil, "BACKGROUND")
                b.bg:SetAllPoints()
                b.bg:SetColorTexture(0.08, 0.1, 0.12, 1)
                b.mark = b:CreateTexture(nil, "ARTWORK")
                b.mark:SetColorTexture(0.25, 0.78, 0.45, 1)
                b.mark:SetSize(3, 18)
                b.label = createText(b, "GameFontHighlight", 11)
                b.label:SetPoint("LEFT", 12, 0)
                b.value = createText(b, "GameFontDisableSmall", 10)
                b.value:SetPoint("RIGHT", -8, 0)
                b:SetScript("OnEnter", function(f) f.bg:SetColorTexture(0.12, 0.18, 0.18, 1) end)
                b:SetScript("OnLeave", function(f) f.bg:SetColorTexture(0.08, 0.1, 0.12, 1) end)
                self.professionButtons[visible] = b
            end
            b:SetPoint("TOPLEFT", 0, -(visible - 1) * 34)
            b.mark:ClearAllPoints()
            b.mark:SetPoint("LEFT", 5, 0)
            b.label:SetText(profession.name)
            if profession.name == self.selectedProfession then
                b.bg:SetColorTexture(0.1, 0.22, 0.17, 1)
                b.mark:Show()
            else
                b.bg:SetColorTexture(0.08, 0.1, 0.12, 1)
                b.mark:Hide()
            end
            b.value:SetText(tostring(profession.skill or 0) .. "/" .. tostring(profession.maxSkill or 300))
            b:SetScript("OnClick", function()
                WP.selectedProfession = profession.name
                WP:UpdateDashboard()
                WP:UpdateTracker()
                WP:UpdateGuideArrow()
            end)
            b:Show()
        end
    end
    self.professionList:SetHeight(math.max(400, visible * 34))
    if self.professionScroll then self.professionScroll:SetVerticalScroll(0) end

    local selected = self.selectedProfession and self.professions[self.selectedProfession]
    if not selected and self.selectedProfession then
        for _, item in ipairs(professions) do if item.name == self.selectedProfession then selected = item; break end end
    end
    local status = WP.Planner.GetStatus(selected)
    local strategy = self.db.settings.strategy or "owned"
    local labels = { fastest = "Fastest", cheapest = "Lowest cost", owned = "Use my materials" }
    for key, button in pairs(self.strategyButtons or {}) do
        local choice = labels[key] or key
        button:SetText((key == strategy and "✓  " or "") .. choice)
    end

    if selected then
        local maxSkill = math.max(tonumber(selected.maxSkill) or 0, 1)
        self.professionTitle:SetText(selected.name)
        self.skillLabel:SetText(status.combinedProgress or string.format("SKILL  %d / %d", selected.skill or 0, selected.maxSkill or 300))
        local currentSkill, currentMax = status.skill or selected.skill or 0, status.maxSkill or maxSkill
        self.dashboardProgress:SetMinMaxValues(0, math.max(currentMax, 1))
        self.dashboardProgress:SetValue(currentSkill)
        self.guideStepTitle:SetText(status.title or "No guide step available")
        self.guideZone:SetText(status.zone and ("⌖  " .. status.zone) or "No route location for this step")
        local body = status.text or "No guide data is available."
        if status.focus and status.focus ~= "" then body = status.focus .. "\n\n" .. body end
        if status.sourceStatus and status.sourceStatus ~= "" then body = body .. "\n\n|cff91a4abGuide data:|r " .. status.sourceStatus end
        if status.routeNote and status.routeNote ~= "" then body = body .. "\n\n|cff91a4abRoute note:|r " .. status.routeNote end
        self.detailText:SetText(body)
        self.dashboardFooter:SetText("SOURCE  WoW-Professions Forever  •  Route references credited in the bundled changelog.")
    else
        self.professionTitle:SetText("Select a profession guide")
        self.skillLabel:SetText("No profession scanned")
        self.dashboardProgress:SetMinMaxValues(0, 1)
        self.dashboardProgress:SetValue(0)
        self.guideStepTitle:SetText("Open a guide from the library")
        self.guideZone:SetText("Your tracked skill progress updates when the game reports it.")
        self.detailText:SetText("This window is the home for profession guides, gathering routes, the route arrow and the tracker.")
        self.dashboardFooter:SetText("No skill data detected yet.")
    end
    if self.UpdateGuideArrow then self:UpdateGuideArrow() end
end

function WP:UpdateTracker()
    if not self.trackerFrame then return end
    local p = self.selectedProfession and self.professions[self.selectedProfession]
    if not p then
        self.trackerFrame.title:SetText("WildProfessions")
        self.trackerFrame.progress:SetText("No profession detected")
        self.trackerFrame.status:SetMinMaxValues(0, 1)
        self.trackerFrame.status:SetValue(0)
        self.trackerFrame.activity:SetText("Open the WildProfessions window for guides and tools.")
        return
    end
    local percent = (p.maxSkill or 0) > 0 and math.floor((p.skill or 0) * 100 / p.maxSkill) or 0
    self.trackerFrame.title:SetText(p.name)
    self.trackerFrame.progress:SetText(string.format("Skill %d / %d  (%d%%)", p.skill or 0, p.maxSkill or 0, percent))
    self.trackerFrame.status:SetMinMaxValues(0, math.max(p.maxSkill or 0, 1))
    self.trackerFrame.status:SetValue(p.skill or 0)
    local guide = WP.Planner.GetStatus(p)
    if guide.status == "active" or guide.status == "trainer" then
        local herbs = guide.herbs and ("\n" .. guide.herbs) or ""
        self.trackerFrame.activity:SetText((guide.title or "Current step") .. "\n" .. (guide.zone or "Route") .. " · target skill " .. tostring(guide.target or 300) .. herbs)
    elseif guide.status == "complete" then
        self.trackerFrame.activity:SetText("Guide complete: " .. p.name .. " " .. tostring(guide.target or 300) .. ".")
    else
        self.trackerFrame.activity:SetText(guide.text or "No route is bundled for this profession yet.")
    end
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


