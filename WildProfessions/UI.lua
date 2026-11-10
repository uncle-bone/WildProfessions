local _, WP = ...

local function createText(parent, font, size, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    if size and fs.SetFont then fs:SetFont("Fonts\\FRIZQT__.TTF", size, "") end
    if color then fs:SetTextColor(color[1], color[2], color[3]) end
    return fs
end

local function itemName(itemID)
    if C_Item and type(C_Item.GetItemNameByID) == "function" then
        local ok, name = pcall(C_Item.GetItemNameByID, itemID)
        if ok and type(name) == "string" then return name end
    end
    if type(GetItemInfo) == "function" then
        local ok, name = pcall(GetItemInfo, itemID)
        if ok and type(name) == "string" then return name end
    end
    if C_Item and type(C_Item.RequestLoadItemDataByID) == "function" then pcall(C_Item.RequestLoadItemDataByID, itemID) end
    return "Item " .. tostring(itemID)
end

local function formatGuideMaterials(materials)
    if type(materials) == "string" then return materials end
    if type(materials) ~= "table" then return nil end
    local lines = {}
    for _, item in ipairs(materials) do
        if type(item) == "table" then
            local label = item.name or item.item
            if not label and item.itemID then label = itemName(item.itemID) end
            label = tostring(label or "Material")
            local count = tonumber(item.count or item.quantity)
            if count then label = label .. " x" .. tostring(count) end
            if item.estimated then label = label .. " (estimated)" end
            lines[#lines + 1] = label
        else
            lines[#lines + 1] = tostring(item)
        end
    end
    return #lines > 0 and table.concat(lines, "\n") or nil
end

local function makeButton(parent, text, width, height, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetText(text)
    button:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
    button:SetPushedTexture("Interface\\Buttons\\WHITE8X8")
    local normal=button:GetNormalTexture();if normal then normal:SetVertexColor(0.09,0.13,0.22,1) end
    local highlight=button:GetHighlightTexture();if highlight then highlight:SetVertexColor(0.24,0.55,0.90,0.40) end
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

local function configureVerticalScroll(scroll, child, step)
    if not scroll or not child then return end
    local function clamp()
        local view = math.max(0, scroll:GetHeight() or 0)
        local content = math.max(view, child:GetHeight() or 0)
        local maximum = math.max(0, content - view)
        scroll:SetVerticalScroll(math.max(0, math.min(maximum, scroll:GetVerticalScroll() or 0)))
    end
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(frame, delta)
        local maximum = math.max(0, (child:GetHeight() or 0) - (frame:GetHeight() or 0))
        frame:SetVerticalScroll(math.max(0, math.min(maximum, (frame:GetVerticalScroll() or 0) - delta * (step or 44))))
    end)
    scroll:SetScript("OnSizeChanged", function(frame)
        local width = frame:GetWidth() or 0
        if width > 0 and child.SetWidth then child:SetWidth(math.max(160, width - 26)) end
        clamp()
    end)
    child:SetScript("OnSizeChanged", clamp)
end

local function farmingKey(name)
    return (name or ""):lower():gsub("[^%a]", "")
end

local function collectFarmingRoutes(professionName)
    local result, seen = {}, {}
    local allFarms = professionName == "All Farms"
    local function add(entry, categoryFallback)
        if type(entry) ~= "table" then return end
        local zone = entry.zone or "No map route"
        local points = type(entry.points) == "table" and entry.points or {}
        local category = entry.category or categoryFallback or "Farming"
        local item = entry.item or entry.name or entry.bracket or "Farm guide"
        local key = table.concat({ tostring(category), tostring(zone), tostring(entry.mapID or ""), tostring(item), tostring(entry.faction or "") }, "|")
        local prior = seen[key]
        if prior then
            if #points > #(prior.points or {}) then prior.points, prior.mapID = points, entry.mapID end
            if (not prior.target or prior.target == 0) and tonumber(entry.skill or entry.target) then prior.target = tonumber(entry.skill or entry.target) end
            if prior.source == "Bundled gathering route" and entry.source then prior.source = entry.source end
            if #points > 0 then prior.unmapped = false end
            return
        end
        local route = {
            category = category, zone = zone, mapID = entry.mapID, points = points,
            item = item, target = tonumber(entry.skill or entry.target) or 0,
            levelRequirement = tonumber(entry.levelRequirement) or 0,
            skillRequirement = tonumber(entry.skillRequirement) or 0,
            faction = entry.faction, source = entry.source or "Bundled gathering route",
            unmapped = entry.unmapped == true or not entry.mapID or #points == 0,
        }
        seen[key] = route
        result[#result + 1] = route
    end

    if allFarms then
        for category, rows in pairs(WP.ZygorGatheringIndex or {}) do
            local categoryName = ({herbalism="Herbalism", mining="Mining", skinning="Skinning", fishing="Fishing"})[category] or category
            for _, row in ipairs(rows) do add(row, categoryName) end
        end
        for key, route in pairs(WP.RouteData or {}) do
            for _, row in ipairs(route.farmRoutes or {}) do add(row, route.name or key) end
        end
    else
        local indexed = WP.ZygorGatheringIndex and WP.ZygorGatheringIndex[farmingKey(professionName)] or {}
        for _, row in ipairs(indexed) do add(row, professionName) end
        local route = WP.RouteData and WP.RouteData[farmingKey(professionName)]
        if route then for _, row in ipairs(route.farmRoutes or {}) do add(row, professionName) end end
    end

    for _, row in ipairs(WP.ZygorFarmingGuideIndex or {}) do
        if allFarms or row.category == professionName then add(row, row.category) end
    end

    local routeNames = allFarms and {"Herbalism", "Mining", "Skinning", "Fishing"} or {professionName}
    for _, routeName in ipairs(routeNames) do
        local route = WP.RouteData and WP.RouteData[farmingKey(routeName)]
        if route then
            for _, step in ipairs(route.steps or {}) do
                for zoneName, mapRoute in pairs(step.mapRoutes or {}) do
                    add({ zone = zoneName, mapID = mapRoute.mapID, points = mapRoute.points,
                        name = step.title, skill = step.min or step.target, faction = mapRoute.faction,
                        source = "Bundled guide route" }, routeName)
                end
            end
            -- Keep every guide zone choice visible; only imported waypoint data can be clicked.
            local mappedZones = {}
            for _, entry in ipairs(result) do
                if entry.category == routeName then mappedZones[entry.zone] = true end
            end
            for _, step in ipairs(route.steps or {}) do
                for _, zoneName in ipairs(step.choices or {}) do
                if not mappedZones[zoneName] then
                    add({ zone=zoneName, item=step.title or "Guide zone recommendation",
                        target=tonumber(step.target) or 0, points={}, unmapped=true,
                        source="Zone recommendation; no imported waypoint route" }, routeName)
                    mappedZones[zoneName] = true
                end
            end
            end
        end
    end
    table.sort(result, function(a, b)
        if a.category ~= b.category then return a.category < b.category end
        if a.target ~= b.target then return a.target < b.target end
        if a.zone ~= b.zone then return a.zone < b.zone end
        return tostring(a.item) < tostring(b.item)
    end)
    return result
end

function WP:CreateUI()
    if self.mainFrame then return end

    local art = WP.SkillUp and WP.SkillUp.Art
    local main = art and art.Window and art.Window("WildProfessionsDashboard", 1080, 700, "WildProfessions")
        or CreateFrame("Frame", "WildProfessionsDashboard", UIParent, "BackdropTemplate")
    main:SetSize(1080, 700)
    main:SetFrameStrata("DIALOG")
    main:SetClampedToScreen(true)
    main:SetMovable(true)
    main:EnableMouse(true)
    main:SetResizable(true)
    if main.SetResizeBounds then pcall(main.SetResizeBounds, main, 900, 600) end
    restorePoint(main, "dashboardPoint", "CENTER", 0, 0)
    local savedSize = self.db.settings.dashboardSize
    if type(savedSize) == "table" then main:SetSize(math.max(980, tonumber(savedSize.width) or 1080), math.max(660, tonumber(savedSize.height) or 700)) end

    local header = main.header or CreateFrame("Frame", nil, main, "BackdropTemplate")
    if not main.header then
        header:SetPoint("TOPLEFT", 8, -8); header:SetPoint("TOPRIGHT", -8, -8); header:SetHeight(62)
        local title = createText(header, "GameFontNormalLarge", 18, {0.94,0.96,1})
        title:SetText("WildProfessions"); title:SetPoint("LEFT",18,0)
    end
    if main.windowIcon then main.windowIcon:SetTexture("Interface\\Icons\\Trade_Herbalism") end
    local navButtons = {}
    local tabDefs = {
        {"More","Interface\\Icons\\INV_Misc_Book_09",function()
            WP:SetMainPage("More"); WP:ShowSystemGuide(WP.systemGuideKind == "camping" and "merchants" or "camping")
        end},
        {"Materials","Interface\\Icons\\INV_Misc_Note_06",function() WP:SetMainPage("Overview"); WP:OpenShoppingList() end},
        {"Farming","Interface\\Icons\\INV_Misc_Map_01",function() WP:SetMainPage("Farming") end},
        {"Leveling","Interface\\Icons\\Trade_Alchemy",function() WP:SetMainPage("Leveling") end},
        {"Overview","Interface\\Icons\\INV_Misc_Herb_01",function() WP:SetMainPage("Overview") end},
    }
    for index, def in ipairs(tabDefs) do
        local tab = CreateFrame("Button", nil, main)
        tab:SetSize(34,34)
        tab:SetPoint("TOPRIGHT", main, "TOPRIGHT", -7, -91 - (index-1)*42)
        tab:SetNormalTexture(def[2])
        tab:GetNormalTexture():SetTexCoord(0.08,0.92,0.08,0.92)
        tab.selection = tab:CreateTexture(nil, "BACKGROUND")
        tab.selection:SetTexture("Interface\\Buttons\\WHITE8X8")
        tab.selection:SetPoint("TOPLEFT", -3, 3)
        tab.selection:SetPoint("BOTTOMRIGHT", 3, -3)
        tab.selection:SetVertexColor(0.72, 0.52, 0.20, 0.55)
        tab.selection:Hide()
        tab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
        tab:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
        tab.slotBorder = tab:CreateTexture(nil, "OVERLAY")
        tab.slotBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
        tab.slotBorder:SetSize(58, 58)
        tab.slotBorder:SetPoint("CENTER")
        tab.pageKey = def[1]
        tab:SetScript("OnClick", def[3])
        tab:SetScript("OnEnter",function(button)
            GameTooltip:SetOwner(button,"ANCHOR_LEFT"); GameTooltip:SetText(button.pageKey); GameTooltip:Show()
        end)
        tab:SetScript("OnLeave",function() GameTooltip:Hide() end)
        navButtons[#navButtons+1]=tab
    end
    self.mainNavButtons = navButtons

    local drag = header
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function()
        if WP.dashboardDocked then
            local left, top = main:GetLeft(), main:GetTop()
            main:ClearAllPoints()
            if type(left)=="number" and type(top)=="number" then main:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left,top) end
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
    sidebar:SetPoint("TOPLEFT", 16, -84)
    sidebar:SetPoint("BOTTOMLEFT", 16, 44)
    sidebar:SetWidth(235)
    if sidebar.SetBackdrop then
        sidebar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        sidebar:SetBackdropColor(0.055, 0.075, 0.12, 0.98)
        sidebar:SetBackdropBorderColor(0.17, 0.25, 0.39, 1)
    end
    local listHeading = createText(sidebar, "GameFontNormal", 12, { 0.38, 0.72, 1.0 })
    listHeading:SetText("YOUR PROFESSION TRACKS")
    listHeading:SetPoint("TOPLEFT", 14, -14)
    local listSub = createText(sidebar, "GameFontDisableSmall", 10)
    listSub:SetText("Live skill  |  next step  |  route options")
    listSub:SetPoint("TOPLEFT", 14, -34)

    local search = CreateFrame("EditBox", nil, sidebar, "InputBoxTemplate")
    search:SetSize(205, 24)
    search:SetPoint("TOPLEFT", 13, -56)
    search:SetAutoFocus(false)
    search:SetTextInsets(8, 6, 2, 2)
    search:SetText(self.db.settings.guideSearch or "")
    search:SetScript("OnTextChanged", function(box)
        WP.db.settings.guideSearch = box:GetText() or ""
        if WP.professionScroll then WP.professionScroll:SetVerticalScroll(0) end
        WP:UpdateDashboard()
    end)
    self.guideSearch = search

    local scroll = CreateFrame("ScrollFrame", nil, sidebar, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -88)
    scroll:SetPoint("BOTTOMRIGHT", -28, 12)
    local list = CreateFrame("Frame", nil, scroll)
    list:SetSize(190, 400)
    scroll:SetScrollChild(list)
    configureVerticalScroll(scroll, list, 48)
    self.professionButtons = {}
    self.professionList, self.professionScroll = list, scroll
    applyWildsparkPanel(sidebar)

    local content = CreateFrame("Frame", nil, main)
    main.contentPane = content
    content:SetPoint("TOPLEFT", 270, -88)
    content:SetPoint("BOTTOMRIGHT", -58, 42)

    local eyebrow = createText(content, "GameFontNormalSmall", 10, { 0.38, 0.72, 1.0 })
    eyebrow:SetText("CURRENT TRAINING PLAN")
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
    progress:SetPoint("TOPLEFT", 8, -62)
    progress:SetPoint("TOPRIGHT", -8, -62)
    progress:SetHeight(14)
    progress:SetMinMaxValues(0, 1)
    progress:SetValue(0)
    progress:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progress:SetStatusBarColor(0.96, 0.62, 0.20, 1)
    local progressBg = progress:CreateTexture(nil, "BACKGROUND")
    progressBg:SetAllPoints()
    progressBg:SetColorTexture(0.1, 0.14, 0.16, 1)
    self.dashboardProgress = progress

    local card = CreateFrame("Frame", nil, content, "BackdropTemplate")
    card:SetPoint("TOPLEFT", 0, -94)
    card:SetPoint("TOPRIGHT", 0, -94)
    card:SetHeight(310)
    if card.SetBackdrop then
        card:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        card:SetBackdropColor(0.065, 0.09, 0.145, 0.99)
        card:SetBackdropBorderColor(0.20, 0.30, 0.46, 1)
    end
    local cardAccent = card:CreateTexture(nil, "ARTWORK")
    cardAccent:SetColorTexture(0.96, 0.62, 0.20, 1)
    cardAccent:SetWidth(3)
    cardAccent:SetPoint("TOPLEFT", 0, 0)
    cardAccent:SetPoint("BOTTOMLEFT", 0, 0)
    local stepLabel = createText(card, "GameFontNormalSmall", 10, { 0.38, 0.72, 1.0 })
    stepLabel:SetText("NEXT MILESTONE")
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
    local zoneButton = makeButton(card, "Choose Zone", 132, 24, function() WP:CycleGuideZone() end)
    zoneButton:SetPoint("TOPRIGHT", -16, -58)
    zoneButton:Hide()
    zoneButton:SetScript("OnEnter", function(button)
        local state = WP:GetCurrentGuideState()
        if GameTooltip then
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Available zones", 1, 0.9, 0.5)
            for _, choice in ipairs(state and state.choices or {}) do GameTooltip:AddLine(choice, 0.85, 0.9, 0.92) end
            GameTooltip:Show()
        end
    end)
    zoneButton:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    self.zoneButton = zoneButton
    self.zoneChoiceButtons = {}
    for i = 1, 3 do
        local choiceButton = makeButton(card, "", 162, 22, function(button)
            if button.zoneName then WP:SetGuideZone(button.zoneName) end
        end)
        choiceButton:SetPoint("TOPLEFT", 18 + ((i - 1) * 170), -88)
        choiceButton:Hide()
        self.zoneChoiceButtons[i] = choiceButton
    end
    local routeList = CreateFrame("ScrollFrame", nil, card)
    routeList:SetPoint("TOPLEFT", 330, -184)
    routeList:SetPoint("BOTTOMRIGHT", -16, 16)
    local routeChild = CreateFrame("Frame", nil, routeList)
    routeChild:SetSize(250, 88)
    routeList:SetScrollChild(routeChild)
    configureVerticalScroll(routeList, routeChild, 48)
    self.gatherRouteChoices = {}
    self.gatherRouteChild = routeChild
    self.gatherRouteScroll = routeList
    local detailScroll = CreateFrame("ScrollFrame", nil, card)
    detailScroll:SetPoint("TOPLEFT", 18, -116)
    detailScroll:SetPoint("BOTTOMLEFT", 18, 16)
    local detailChild = CreateFrame("Frame", nil, detailScroll)
    detailChild:SetSize(250, 180)
    detailScroll:SetScrollChild(detailChild)
    configureVerticalScroll(detailScroll, detailChild, 42)
    self.detailScroll, self.detailTextChild = detailScroll, detailChild
    local detail = createText(detailChild, "GameFontHighlight", 12, { 0.78, 0.84, 0.87 })
    detail:SetPoint("TOPLEFT", 0, 0)
    detail:SetWidth(250)
    detail:SetHeight(180)
    detail:SetJustifyH("LEFT")
    detail:SetJustifyV("TOP")
    self.detailText = detail

    local divider = card:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.16, 0.25, 0.27, 1)
    divider:SetSize(1, 132)
    divider:SetPoint("TOPLEFT", 315, -120)
    local reagentHeading = createText(card, "GameFontNormalSmall", 10, { 0.38, 0.72, 1.0 })
    reagentHeading:SetText("CRAFTING REAGENTS")
    reagentHeading:SetPoint("TOPLEFT", 330, -118)
    self.reagentHeading = reagentHeading
    local reagentScroll = CreateFrame("ScrollFrame",nil,card)
    local reagentChild = CreateFrame("Frame",nil,reagentScroll)
    reagentChild:SetSize(250,180)
    reagentScroll:SetScrollChild(reagentChild)
    configureVerticalScroll(reagentScroll,reagentChild,42)
    local reagentText = createText(reagentChild, "GameFontHighlightSmall", 11, { 0.82, 0.87, 0.89 })
    reagentText:SetPoint("TOPLEFT", 0, 0)
    reagentText:SetWidth(250)
    reagentText:SetJustifyH("LEFT")
    reagentText:SetJustifyV("TOP")
    self.reagentText = reagentText
    self.reagentScroll,self.reagentTextChild=reagentScroll,reagentChild
    local routeHeading = createText(card,"GameFontNormalSmall",10,{0.38,0.72,1.0})
    routeHeading:SetText("AVAILABLE FIELD ROUTES")
    routeHeading:SetPoint("TOPLEFT",330,-118)
    self.routeHeading=routeHeading
    routeHeading:Hide()

    local function layoutGuideCard()
        local width = card:GetWidth() or 570
        local columnWidth = math.max(190, (width - 62) / 2)
        detailScroll:ClearAllPoints()
        detailScroll:SetPoint("TOPLEFT", 18, -116)
        detailScroll:SetPoint("BOTTOMLEFT", 18, 16)
        detailScroll:SetWidth(columnWidth)
        detailChild:SetWidth(math.max(170, columnWidth - 20))
        detail:SetWidth(math.max(170, columnWidth - 20))
        divider:ClearAllPoints()
        divider:SetPoint("TOPLEFT", 30 + columnWidth, -112)
        divider:SetPoint("BOTTOMLEFT", 30 + columnWidth, 16)
        reagentHeading:ClearAllPoints()
        reagentHeading:SetPoint("TOPLEFT", 44 + columnWidth, -118)
        routeHeading:ClearAllPoints()
        routeHeading:SetPoint("TOPLEFT", 44 + columnWidth, -118)
        reagentScroll:ClearAllPoints()
        reagentScroll:SetPoint("TOPLEFT", 44 + columnWidth, -136)
        reagentScroll:SetPoint("BOTTOMRIGHT", -16, 16)
        reagentChild:SetWidth(math.max(170,columnWidth-8))
        reagentText:SetWidth(math.max(170,columnWidth-8))
        routeList:ClearAllPoints()
        routeList:SetPoint("TOPLEFT", 40 + columnWidth, -142)
        routeList:SetPoint("BOTTOMRIGHT", -16, 16)
        routeChild:SetWidth(math.max(170, columnWidth - 10))
    end
    card:SetScript("OnSizeChanged", layoutGuideCard)
    applyWildsparkPanel(card)
    layoutGuideCard()

    local prefLabel = createText(content, "GameFontNormalSmall", 10, { 0.38, 0.72, 1.0 })
    prefLabel:SetText("ROUTE PREFERENCE")
    prefLabel:SetPoint("TOPLEFT", 8, -424)
    local strategyButtons = {}
    local strategyDefs = {
        { key = "fastest", text = "Fastest" },
        { key = "cheapest", text = "Lowest cost" },
        { key = "owned", text = "Use my materials" },
    }
    for i, def in ipairs(strategyDefs) do
        local b = makeButton(content, def.text, 145, 26, function() WP.Planner.SetStrategy(def.key) end)
        b:SetPoint("TOPLEFT", 8 + (i - 1) * 153, -444)
        strategyButtons[def.key] = b
    end
    self.strategyButtons = strategyButtons

    local toolsLabel = createText(content, "GameFontNormalSmall", 10, { 0.38, 0.72, 1.0 })
    toolsLabel:SetText("GUIDE TOOLS")
    toolsLabel:SetPoint("TOPLEFT", 8, -486)
    local function toolButton(text, x, onClick)
        local b = makeButton(content, text, 135, 30, onClick)
        b:SetPoint("TOPLEFT", x, -506)
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

    -- Farming has its own full-size atlas. These routes are intentionally separate
    -- from the skill-up guide picker so players can browse every gathered item/zone.
    local farming = CreateFrame("Frame", "WildProfessionsFarmingGuides", main, "BackdropTemplate")
    farming:SetPoint("TOPLEFT", 10, -76)
    farming:SetPoint("BOTTOMRIGHT", -48, 36)
    farming:SetFrameLevel(main:GetFrameLevel() + 10)
    if farming.SetBackdrop then
        farming:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=false, edgeSize=12, insets={left=4,right=4,top=4,bottom=4} })
        farming:SetBackdropColor(0.035,0.045,0.06,0.99)
    end
    local farmTitle = createText(farming,"GameFontNormalLarge",20,{0.38,0.72,1.0})
    farmTitle:SetPoint("TOPLEFT",18,-18)
    farmTitle:SetText("Farming & Gathering Atlas")
    local farmBack = makeButton(farming,"Back to Leveling Guides",168,26,function() WP:SetMainPage("Leveling") end)
    farmBack:SetPoint("TOPRIGHT",-18,-16)
    local farmHint = createText(farming,"GameFontHighlightSmall",11,{0.75,0.82,0.86})
    farmHint:SetPoint("TOPLEFT",20,-50)
    farmHint:SetPoint("RIGHT",-18,0)
    farmHint:SetJustifyH("LEFT")
    farmHint:SetText("Browse all gathered-material routes separately from leveling guides. Text-only zone choices are listed without invented map paths.")
    local farmFilters = {}
    for i, name in ipairs({"All Farms","Herbalism","Mining","Skinning","Fishing"}) do
        local button = makeButton(farming,name,104,26,function(b)
            WP.selectedFarmingProfession = b.professionName
            WP:UpdateFarmingGuides()
        end)
        button.professionName = name
        button:SetPoint("TOPLEFT",18 + (i-1)*110,-76)
        farmFilters[name] = button
    end
    self.farmingFilterButtons = farmFilters
    local farmSkill = createText(farming,"GameFontHighlight",11,{0.85,0.9,0.92})
    farmSkill:SetPoint("TOPLEFT",18,-106)
    farmSkill:SetPoint("RIGHT",farmBack,"LEFT",-14,0)
    farmSkill:SetJustifyH("RIGHT")
    self.farmingSkillLabel = farmSkill
    local farmSearch = CreateFrame("EditBox",nil,farming,"InputBoxTemplate")
    farmSearch:SetSize(260,24)
    farmSearch:SetPoint("TOPLEFT",18,-132)
    farmSearch:SetAutoFocus(false)
    farmSearch:SetTextInsets(8,6,2,2)
    farmSearch:SetText("Filter by zone or material")
    farmSearch:SetScript("OnEditFocusGained",function(box) if box:GetText()=="Filter by zone or material" then box:SetText("") end end)
    farmSearch:SetScript("OnTextChanged",function() if WP.UpdateFarmingGuides then WP:UpdateFarmingGuides() end end)
    self.farmingSearch = farmSearch
    local farmScroll = CreateFrame("ScrollFrame",nil,farming,"UIPanelScrollFrameTemplate")
    farmScroll:SetPoint("TOPLEFT",18,-164)
    farmScroll:SetPoint("BOTTOMRIGHT",-34,18)
    local farmList = CreateFrame("Frame",nil,farmScroll)
    farmList:SetSize(600,1)
    farmScroll:SetScrollChild(farmList)
    configureVerticalScroll(farmScroll,farmList,56)
    self.farmingScroll,self.farmingList,self.farmingRouteRows=farmScroll,farmList,{}
    farming:Hide()
    self.farmingFrame=farming
    applyWildsparkPanel(farming)

    local systemGuide = CreateFrame("Frame", nil, main, "BackdropTemplate")
    systemGuide:SetPoint("TOPLEFT", main, "TOPLEFT", 26, -78)
    systemGuide:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -26, 42)
    systemGuide:SetFrameLevel(main:GetFrameLevel() + 30)
    if systemGuide.SetBackdrop then
        systemGuide:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=false, edgeSize=14, insets={left=4,right=4,top=4,bottom=4} })
        systemGuide:SetBackdropColor(0.035,0.045,0.06,0.99)
    end
    local guideTitle = createText(systemGuide,"GameFontNormalLarge",20,{0.38,0.72,1.0})
    guideTitle:SetPoint("TOPLEFT",18,-18)
    guideTitle:SetText("Forever Systems")
    local guideClose = makeButton(systemGuide,"Back to Profession Guides",190,28,function() systemGuide:Hide() end)
    guideClose:SetPoint("TOPRIGHT",-18,-16)
    local guideBody = createText(systemGuide,"GameFontHighlight",14,{0.85,0.9,0.92})
    guideBody:SetPoint("TOPLEFT",18,-64)
    guideBody:SetPoint("BOTTOMRIGHT",-18,18)
    guideBody:SetJustifyH("LEFT")
    guideBody:SetJustifyV("TOP")
    guideBody:SetWordWrap(true)
    self.systemGuideText = guideBody
    self.systemGuideFrame = systemGuide
    applyWildsparkPanel(systemGuide)
    systemGuide:Hide()

    local overview = CreateFrame("Frame", "WildProfessionsOverview", main, "BackdropTemplate")
    overview:SetPoint("TOPLEFT", 16, -84)
    overview:SetPoint("BOTTOMRIGHT", -48, 44)
    overview:SetFrameLevel(main:GetFrameLevel() + 5)
    if overview.SetBackdrop then
        overview:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1 })
        overview:SetBackdropColor(0.045,0.065,0.105,0.98)
        overview:SetBackdropBorderColor(0.17,0.25,0.39,1)
    end
    local overviewEyebrow=createText(overview,"GameFontNormalSmall",10,{0.98,0.61,0.20})
    overviewEyebrow:SetText("CHARACTER WORKSHOP")
    overviewEyebrow:SetPoint("TOPLEFT",22,-18)
    local overviewTitle=createText(overview,"GameFontNormalLarge",25,{0.94,0.97,1.0})
    overviewTitle:SetText("Profession Desk")
    overviewTitle:SetPoint("TOPLEFT",22,-38)
    local overviewSummary=createText(overview,"GameFontHighlight",12,{0.72,0.82,0.94})
    overviewSummary:SetPoint("TOPLEFT",24,-72)
    overviewSummary:SetPoint("RIGHT",-22,0)
    overviewSummary:SetJustifyH("LEFT")
    self.overviewSummary=overviewSummary
    local actions={
        {"OPEN LEVELING GUIDES",function()
            local list=WP:GetProfessionList()
            if WP.lastTrackedProfession and WP.professions[WP.lastTrackedProfession] then WP.selectedProfession=WP.lastTrackedProfession
            elseif #list>0 then WP.selectedProfession=list[1].name end
            WP:UpdateDashboard();WP:SetMainPage("Leveling")
        end},
        {"FARMING & GATHERING",function() WP:SetMainPage("Farming") end},
        {"SHOPPING NOTES",function() WP:OpenShoppingList() end},
        {"CAMPING & MERCHANT FAVOR",function() WP:SetMainPage("More");WP:ShowSystemGuide("camping") end},
    }
    for i,action in ipairs(actions) do
        local button=makeButton(overview,action[1],220,42,action[2])
        button:SetPoint("TOPLEFT",22+(i-1)*236,-101)
        button:SetHeight(42)
    end
    local guideListTitle=createText(overview,"GameFontNormal",13,{0.38,0.72,1.0})
    guideListTitle:SetText("YOUR GUIDE LIBRARY")
    guideListTitle:SetPoint("TOPLEFT",22,-158)
    local guideListHint=createText(overview,"GameFontDisableSmall",10)
    guideListHint:SetText("Select a profession card to continue at its current skill.")
    guideListHint:SetPoint("LEFT",guideListTitle,"RIGHT",12,0)
    local overviewScroll=CreateFrame("ScrollFrame",nil,overview,"UIPanelScrollFrameTemplate")
    overviewScroll:SetPoint("TOPLEFT",18,-182)
    overviewScroll:SetPoint("BOTTOMRIGHT",-30,18)
    local overviewList=CreateFrame("Frame",nil,overviewScroll)
    overviewList:SetSize(900,1)
    overviewScroll:SetScrollChild(overviewList)
    configureVerticalScroll(overviewScroll,overviewList,58)
    self.overviewFrame,self.overviewScroll,self.overviewList=overview,overviewScroll,overviewList
    applyWildsparkPanel(overview)
    self.overviewCards={}
    overview:Hide()

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

    local tracker = WP.SkillUp and WP.SkillUp.Art and WP.SkillUp.Art.Window
        and WP.SkillUp.Art.Window("WildProfessionsTracker", 340, 236, "PROFESSION TRACKER")
        or CreateFrame("Frame", "WildProfessionsTracker", UIParent, "BackdropTemplate")
    tracker:ClearAllPoints()
    tracker:SetSize(340, 236)
    tracker:SetFrameStrata("MEDIUM")
    tracker:SetClampedToScreen(true)
    tracker:SetMovable(true)
    tracker:EnableMouse(true)
    if tracker.SetBackdrop then
        tracker:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        tracker:SetBackdropColor(0.025, 0.035, 0.06, 0.98)
        tracker:SetBackdropBorderColor(0.30, 0.45, 0.68, 1)
    end
    restorePoint(tracker, "trackerPoint", "TOPRIGHT", -80, -220)
    tracker:RegisterForDrag("LeftButton")
    tracker:SetScript("OnDragStart", function(f) if not WP.db.settings.trackerLocked then f:StartMoving() end end)
    tracker:SetScript("OnDragStop", function(f) f:StopMovingOrSizing(); savePoint(f, "trackerPoint") end)
    tracker.title = createText(tracker, "GameFontNormal", 13, { 0.38, 0.72, 1.0 })
    tracker.title:SetPoint("TOPLEFT", 14, -58)
    tracker.progress = createText(tracker, "GameFontHighlight", 11)
    tracker.progress:SetPoint("TOPLEFT", 14, -80)
    tracker.status = CreateFrame("StatusBar", nil, tracker)
    tracker.status:SetSize(310, 10)
    tracker.status:SetPoint("TOPLEFT", 14, -99)
    tracker.status:SetMinMaxValues(0, 1)
    tracker.status:SetValue(0)
    tracker.status:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    tracker.status:SetStatusBarColor(0.96, 0.62, 0.20, 1)
    local trackerBackground = tracker.status:CreateTexture(nil, "BACKGROUND")
    trackerBackground:SetAllPoints()
    trackerBackground:SetColorTexture(0.1, 0.14, 0.16, 1)
    tracker.activity = createText(tracker, "GameFontHighlightSmall", 10, { 0.78, 0.84, 0.87 })
    tracker.activity:SetPoint("TOPLEFT", 14, -120)
    tracker.activity:SetWidth(310)
    tracker.activity:SetHeight(98)
    tracker.activity:SetJustifyH("LEFT")
    tracker.activity:SetJustifyV("TOP")
    local trackerClose = tracker.windowClose or CreateFrame("Button", nil, tracker, "UIPanelCloseButton")
    trackerClose:SetSize(22, 22)
    if not tracker.windowClose then trackerClose:SetPoint("TOPRIGHT", -2, -2) end
    trackerClose:SetScript("OnClick", function() tracker:Hide(); WP.db.settings.trackerVisible = false end)
    if tracker.header then
        tracker.header:SetScript("OnDragStop", function()
            tracker:StopMovingOrSizing()
            savePoint(tracker, "trackerPoint")
        end)
    end
    self.trackerFrame = tracker
    if self.db.settings.trackerVisible == false then tracker:Hide() end

    self:SetMainPage("Overview")
    self:UpdateOverview()
    main:SetScript("OnSizeChanged", function(f, w, h)
        WP.db.settings.dashboardSize = { width = w, height = h }
        if WP.UpdateOverview then WP:UpdateOverview() end
    end)
end

function WP:SetMainPage(page)
    page=page or "Overview"
    self.currentMainPage=page
    local overview=self.overviewFrame
    if overview then overview:Hide() end
    if self.professionScroll and self.professionScroll:GetParent() then self.professionScroll:GetParent():Show() end
    if self.mainFrame then
        for _,child in ipairs({self.mainFrame:GetChildren()}) do
            if child==overview or child==self.farmingFrame or child==self.systemGuideFrame then child:Hide() end
        end
    end
    if page=="Overview" or page=="More" then
        if self.overviewFrame then self.overviewFrame:Show() end
        if self.professionScroll and self.professionScroll:GetParent() then self.professionScroll:GetParent():Hide() end
        if self.mainFrame and self.mainFrame.contentPane then self.mainFrame.contentPane:Hide() end
    elseif page=="Farming" then
        if self.professionScroll and self.professionScroll:GetParent() then self.professionScroll:GetParent():Hide() end
        if self.mainFrame and self.mainFrame.contentPane then self.mainFrame.contentPane:Hide() end
        if self.farmingFrame then self.farmingFrame:Show(); self:UpdateFarmingGuides() end
    else
        if self.overviewFrame then self.overviewFrame:Hide() end
        if self.professionScroll and self.professionScroll:GetParent() then self.professionScroll:GetParent():Show() end
        if self.mainFrame and self.mainFrame.contentPane then self.mainFrame.contentPane:Show() end
        if self.farmingFrame then self.farmingFrame:Hide() end
    end
    for _,button in ipairs(self.mainNavButtons or {}) do
        local selected=button.pageKey==page
        button:SetAlpha(selected and 1 or 0.62)
        if button.selection then button.selection:SetShown(selected) end
    end
end

function WP:UpdateOverview()
    if not self.overviewList then return end
    local guides=self:GetProfessionList()
    local learned=0
    for _,guide in ipairs(guides) do if self.professions[guide.name] then learned=learned+1 end end
    self.overviewSummary:SetText(string.format("%d profession skills detected  |  %d guides ready  |  Your tracker follows the next unfinished step for a learned profession.",learned,#guides))
    local width=math.max(220,(self.overviewScroll:GetWidth() or 900)-26)
    local columns=3
    local gap=12
    local cardWidth=math.max(210,(width-gap*(columns-1))/columns)
    local rowHeight=104
    for index,guide in ipairs(guides) do
        local card=self.overviewCards[index]
        if not card then
            card=CreateFrame("Button",nil,self.overviewList,"BackdropTemplate")
            card:SetHeight(94)
            applyWildsparkPanel(card)
            card.name=createText(card,"GameFontNormal",13,{0.94,0.97,1.0})
            card.name:SetPoint("TOPLEFT",12,-10)
            card.name:SetPoint("RIGHT",-90,0)
            card.skill=createText(card,"GameFontHighlightSmall",10,{0.98,0.72,0.34})
            card.skill:SetPoint("TOPRIGHT",-10,-12)
            card.step=createText(card,"GameFontHighlightSmall",10,{0.72,0.82,0.94})
            card.step:SetPoint("TOPLEFT",12,-34)
            card.step:SetPoint("RIGHT",-10,0)
            card.step:SetJustifyH("LEFT")
            card.step:SetWordWrap(true)
            card:SetScript("OnEnter",function(f) f:SetBackdropColor(0.11,0.17,0.27,1) end)
            card:SetScript("OnLeave",function(f) f:SetBackdropColor(0.075,0.10,0.16,1) end)
            card:SetScript("OnClick",function(f)
                if not f.guide then return end
                WP.selectedProfession=f.guide.name
                if WP.professions[f.guide.name] then WP.lastTrackedProfession=f.guide.name end
                WP:UpdateDashboard()
                WP:SetMainPage("Leveling")
            end)
            self.overviewCards[index]=card
        end
        local col=(index-1)%columns
        local row=math.floor((index-1)/columns)
        card:ClearAllPoints()
        card:SetSize(cardWidth,94)
        card:SetPoint("TOPLEFT",col*(cardWidth+gap),-row*rowHeight)
        card.name:SetText(guide.name)
        local current=self.professions[guide.name]
        card.skill:SetText(current and string.format("%d/%d",current.skill or 0,current.maxSkill or 300) or "GUIDE")
        local state=self:GetGuideState(current or guide)
        local line=state and (state.title or state.text) or "Guide ready — select to view steps."
        if state and state.zone then line=line.."  |  "..state.zone end
        card.step:SetText(line)
        card.guide=guide
        card:Show()
    end
    for i=#guides+1,#self.overviewCards do self.overviewCards[i]:Hide() end
    local rows=math.ceil(#guides/columns)
    self.overviewList:SetWidth(width)
    self.overviewList:SetHeight(math.max(1,rows*rowHeight))
    self.overviewScroll:SetVerticalScroll(math.min(self.overviewScroll:GetVerticalScroll() or 0,math.max(0,self.overviewList:GetHeight()-self.overviewScroll:GetHeight())))
end

function WP:UpdateFarmingGuides()
    if not self.farmingList then return end
    local profession = self.selectedFarmingProfession or "All Farms"
    self.selectedFarmingProfession = profession
    local skill = self.professions and self.professions[profession]
    if profession == "All Farms" then
        self.farmingSkillLabel:SetText(string.format("%d route entries | click mapped routes to open their map", #(WP.ZygorFarmingGuideIndex or {})))
    else
        self.farmingSkillLabel:SetText(skill and string.format("Your %s: %d/%d",profession,skill.skill or 0,skill.maxSkill or 300) or ("Your "..profession.." skill is not learned"))
    end
    for name, button in pairs(self.farmingFilterButtons or {}) do
        button:SetText((name==profession and "[x] " or "")..name)
    end
    local routes=collectFarmingRoutes(profession)
    local query=(self.farmingSearch and self.farmingSearch:GetText() or ""):lower()
    if query=="filter by zone or material" then query="" end
    for _,row in ipairs(self.farmingRouteRows or {}) do row:Hide() end
    local count=0
    for _,entry in ipairs(routes) do
        local searchable=(tostring(entry.category).." "..entry.zone.." "..tostring(entry.item).." "..tostring(entry.target).." "..tostring(entry.faction or "")):lower()
        if query=="" or searchable:find(query,1,true) then
            count=count+1
            local row=self.farmingRouteRows[count]
            if not row then
                row=CreateFrame("Button",nil,self.farmingList,"BackdropTemplate")
            row:SetHeight(48)
                if row.SetBackdrop then row:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1});row:SetBackdropColor(0.075,0.10,0.16,1);row:SetBackdropBorderColor(0.14,0.22,0.23,1) end
                row.title=createText(row,"GameFontNormal",12,{0.92,0.95,0.93})
                row.title:SetPoint("TOPLEFT",12,-7)
                row.title:SetPoint("RIGHT",-150,0)
                row.title:SetJustifyH("LEFT")
                row.detail=createText(row,"GameFontDisableSmall",10,{0.70,0.78,0.80})
                row.detail:SetPoint("BOTTOMLEFT",12,7)
                row.detail:SetPoint("RIGHT",-8,0)
                row.detail:SetJustifyH("LEFT")
                row:SetScript("OnEnter",function(f) if f.route then f:SetBackdropColor(0.12,0.22,0.34,1) end end)
                row:SetScript("OnLeave",function(f) if f.route then f:SetBackdropColor(0.075,0.10,0.16,1) end end)
                row:SetScript("OnClick",function(f)
                    if not f.route or f.route.unmapped then return end
                    WP.activeFarmRoute=f.route
                    if f.professionName ~= "All Farms" then
                        WP.selectedProfession=f.professionName
                        WP:SetGatheringRoute(f.route,f.professionName)
                    end
                    WP.mapRoutesVisible=true
                    if C_Map and C_Map.OpenWorldMap then pcall(C_Map.OpenWorldMap,f.route.mapID) elseif SetMapByID then if ToggleWorldMap then ToggleWorldMap() end;pcall(SetMapByID,f.route.mapID) end
                    if WP.mapOverlayHost then WP.mapOverlayHost:Show() end
                    if WP.attachMapOverlay then WP.attachMapOverlay() end
                    if WP.UpdateGuideArrow then WP:UpdateGuideArrow() end
                end)
                self.farmingRouteRows[count]=row
            end
            row:SetPoint("TOPLEFT",0,-(count-1)*54)
            row:SetPoint("RIGHT",self.farmingList,"RIGHT",-4,0)
            row.title:SetText((profession=="All Farms" and (tostring(entry.category)..": ") or "")..(entry.item or "Farming guide"))
            local faction=entry.faction and (" | "..entry.faction) or ""
            if entry.unmapped then
                local requirement = (entry.target and entry.target > 0) and string.format("skill %d+",entry.target) or ((entry.levelRequirement and entry.levelRequirement > 0) and string.format("character level %d+",entry.levelRequirement) or "skill bracket not listed")
                row.detail:SetText(string.format("%s  |  %s%s  |  No mapped coordinates  |  Zone recommendation",entry.zone,requirement,faction))
                row:SetBackdropColor(0.045,0.06,0.10,1)
            else
                local requirement = (entry.target and entry.target > 0) and string.format("skill %d+",entry.target) or ((entry.levelRequirement and entry.levelRequirement > 0) and string.format("character level %d+",entry.levelRequirement) or "skill bracket not listed")
                row.detail:SetText(string.format("%s  |  %s%s  |  %d mapped waypoints  |  Imported route",entry.zone,requirement,faction,#entry.points))
                row:SetBackdropColor(0.075,0.10,0.16,1)
            end
            row.professionName=profession
            row.route=entry
            row:Show()
        end
    end
    self.farmingList:SetHeight(math.max(1,count*54))
    self.farmingScroll:SetVerticalScroll(math.min(self.farmingScroll:GetVerticalScroll(),math.max(0,self.farmingList:GetHeight()-self.farmingScroll:GetHeight())))
    if count==0 then
        self.farmingEmpty=self.farmingEmpty or createText(self.farmingList,"GameFontHighlight",12,{0.78,0.84,0.87})
        self.farmingEmpty:SetPoint("TOPLEFT",12,-12)
        self.farmingEmpty:SetText("No farming guides match this filter. Clear the search or choose another category.")
        self.farmingEmpty:Show()
    elseif self.farmingEmpty then self.farmingEmpty:Hide() end
end

function WP:UpdateDashboard()
    if not self.mainFrame then return end
    local professions = self:GetProfessionList()
    if not self.selectedProfession and #professions > 0 then
        for _, item in ipairs(professions) do if item.name == "Herbalism" then self.selectedProfession = item.name; break end end
        if not self.selectedProfession then self.selectedProfession = professions[1].name end
    end
    if self.selectedProfession and self.professions[self.selectedProfession] then
        self.lastTrackedProfession = self.selectedProfession
    elseif not self.lastTrackedProfession then
        for _, item in ipairs(professions) do
            if self.professions[item.name] then self.lastTrackedProfession = item.name; break end
        end
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
                b:SetSize(math.max(150, self.professionList:GetWidth() or 190), 30)
                b.bg = b:CreateTexture(nil, "BACKGROUND")
                b.bg:SetAllPoints()
                b.bg:SetColorTexture(0.08, 0.1, 0.12, 1)
                b.mark = b:CreateTexture(nil, "ARTWORK")
                b.mark:SetColorTexture(0.96, 0.62, 0.20, 1)
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
            if profession.name == "Fishing + Cooking" then
                local combined = self.RouteData and self.RouteData.fishingcooking and self.RouteData.fishingcooking.skills or {}
                local fishingSkill = (self.professions.Fishing and self.professions.Fishing.skill) or (combined.Fishing and combined.Fishing.skill) or 0
                local cookingSkill = (self.professions.Cooking and self.professions.Cooking.skill) or (combined.Cooking and combined.Cooking.skill) or 0
                b.value:SetText("F" .. tostring(fishingSkill) .. " C" .. tostring(cookingSkill))
            else
                b.value:SetText(tostring(profession.skill or 0) .. "/" .. tostring(profession.maxSkill or 300))
            end
            b:SetScript("OnClick", function()
                WP.selectedProfession = profession.name
                WP.activeFarmRoute = nil
                if WP.professions and WP.professions[profession.name] then WP.lastTrackedProfession = profession.name end
                WP:UpdateDashboard()
                WP:UpdateTracker()
                WP:UpdateGuideArrow()
            end)
            b:Show()
        end
    end
    self.professionList:SetHeight(math.max(400, visible * 34))
    if self.professionScroll then
        local maxScroll = math.max(0, (self.professionList:GetHeight() or 0) - self.professionScroll:GetHeight())
        self.professionScroll:SetVerticalScroll(math.min(self.professionScroll:GetVerticalScroll(), maxScroll))
    end

    local selected = self.selectedProfession and self.professions[self.selectedProfession]
    if not selected and self.selectedProfession then
        for _, item in ipairs(professions) do if item.name == self.selectedProfession then selected = item; break end end
    end
    local status = WP.Planner.GetStatus(selected)
    local strategy = self.db.settings.strategy or "owned"
    local labels = { fastest = "Fastest", cheapest = "Lowest cost", owned = "Use my materials" }
    for key, button in pairs(self.strategyButtons or {}) do
        local choice = labels[key] or key
        button:SetText((key == strategy and ">  " or "") .. choice)
    end

    if selected then
        local priorDetailScroll = self.detailScroll and self.detailScroll:GetVerticalScroll() or 0
        local maxSkill = math.max(tonumber(selected.maxSkill) or 0, 1)
        self.professionTitle:SetText(selected.name)
        self.skillLabel:SetText(status.combinedProgress or string.format("SKILL  %d / %d", selected.skill or 0, selected.maxSkill or 300))
        local currentSkill, currentMax = status.skill or selected.skill or 0, status.maxSkill or maxSkill
        self.dashboardProgress:SetMinMaxValues(0, math.max(currentMax, 1))
        self.dashboardProgress:SetValue(currentSkill)
        if status.choices and #status.choices > 1 then
            self.zoneButton:Hide()
            for i, button in ipairs(self.zoneChoiceButtons or {}) do
                local zoneName = status.choices[i]
                button.zoneName = zoneName
                if zoneName then
                    button:SetText((zoneName == status.selectedZone and "[x] " or "") .. zoneName)
                    button:Show()
                else
                    button:Hide()
                end
            end
        else
            self.zoneButton:Hide()
            for _, button in ipairs(self.zoneChoiceButtons or {}) do button:Hide() end
        end
        self.guideStepTitle:SetText(status.title or "No guide step available")
        self.guideZone:SetText(status.zone and ("⌖  " .. status.zone) or "No route location for this step")
        local body = status.text or "No guide data is available."
        if status.focus and status.focus ~= "" then body = status.focus .. "\n\n" .. body end
        if status.step and status.step.carryForward and status.step.carryForward ~= "" then
            body = body .. "\n\n|cff67d5a3CARRY FORWARD|r\n" .. status.step.carryForward
        end
        local combinedTasks = WP.Planner.FormatCombinedTasks and WP.Planner.FormatCombinedTasks(status) or ""
        if combinedTasks ~= "" then body = combinedTasks .. "\n\n" .. body end
        local cookingTask = status.activeTasks and status.activeTasks.Cooking
        if cookingTask then
            body = body .. "\n\nCooking materials follow the selected guide recipe branch. Use fish already caught before adding fish to a shopping list; itemized carry-forward counts are not yet available for this section."
        end
        local fishingTask = status.activeTasks and status.activeTasks.Fishing
        if fishingTask and WP.Planner.GetGatheringChoices then
            local fishingRoutes = WP.Planner.GetGatheringChoices(selected)
            local shown, zones = 0, {}
            for _, entry in ipairs(fishingRoutes) do
                if entry.zone and entry.mapID and entry.points and not zones[entry.zone] then
                    zones[entry.zone] = true
                    shown = shown + 1
                    if shown <= 4 then
                        body = body .. string.format("\n  Fishing route option: %s (%s)", entry.zone, entry.bracket or "farming guide")
                    end
                end
            end
            if shown > 4 then body = body .. string.format("\n  %d additional fishing route options available in the route list.", shown - 4) end
        end
        if status.sourceStatus and status.sourceStatus ~= "" then body = body .. "\n\n|cff91a4abGuide data:|r " .. status.sourceStatus end
        if status.routeNote and status.routeNote ~= "" then body = body .. "\n\n|cff91a4abRoute note:|r " .. status.routeNote end
        local pointCount = status.routePoints and #status.routePoints or 0
        if pointCount > 0 then body = body .. "\n\nROUTE  " .. pointCount .. " waypoints. Click Show Map Route to see the connected path." end
        local guideRows = WP.GetGuideSteps and WP:GetGuideSteps(selected) or {}
        if #guideRows > 0 then
            body = body .. "\n\n|cff67d5a3GUIDE PROGRESS|r"
            for _, row in ipairs(guideRows) do
                local marker = row.complete and "[x] " or (row.current and "> " or "[ ] ")
                local label = (row.skill and (row.skill .. ": ") or "") .. (row.title or "Guide step")
                body = body .. "\n" .. marker .. label .. (row.zone and (" - " .. row.zone) or "")
                if row.skill and row.target then body = body .. string.format(" (%d -> %d)", row.skillValue or 0, row.target) end
                if row.recipeOptions then body = body .. "\n    Choose one: " .. row.recipeOptions end
                if row.estimate then body = body .. "\n    Estimated: " .. row.estimate end
                if row.instructions and row.current then body = body .. "\n    " .. row.instructions end
            end
        end
        self.detailText:SetText(body)
        local detailHeight = math.max(140, (self.detailText:GetStringHeight() or 0) + 8)
        self.detailText:SetHeight(detailHeight)
        self.detailTextChild:SetHeight(detailHeight)
        self.detailScroll:SetVerticalScroll(math.min(priorDetailScroll, math.max(0, detailHeight - self.detailScroll:GetHeight())))
        local isGathering = WP.Planner.IsGatheringProfession and WP.Planner.IsGatheringProfession(selected.name)
        if isGathering then
            self.reagentText:Hide()
            self.reagentScroll:Hide()
            self.reagentHeading:Hide()
            self.routeHeading:SetText("AVAILABLE ZONES & ROUTES")
            self.routeHeading:Show()
            if self.gatherRouteScroll then self.gatherRouteScroll:Show() end
        else
            self.routeHeading:Hide()
            self.reagentHeading:SetText("GUIDE MATERIALS")
            self.reagentHeading:Show()
            self.reagentScroll:Show()
            self.reagentText:Show()
            local materials = status.step and (status.step.materials or status.step.materialSummary)
            materials = formatGuideMaterials(materials)
            self.reagentText:SetText(type(materials) == "string" and materials ~= "" and materials or "This guide section does not yet have a verified itemized material list. Follow the source recipe choices and keep materials reserved for later steps.")
            local materialHeight=math.max(80,(self.reagentText:GetStringHeight() or 0)+8)
            self.reagentText:SetHeight(materialHeight)
            self.reagentTextChild:SetHeight(materialHeight)
            self.reagentScroll:SetVerticalScroll(math.min(self.reagentScroll:GetVerticalScroll(),math.max(0,materialHeight-self.reagentScroll:GetHeight())))
            if self.gatherRouteScroll then self.gatherRouteScroll:Hide() end
        end
        local gatherRoutes = WP.Planner.GetGatheringChoices(selected)
        for _, button in ipairs(self.gatherRouteChoices or {}) do button:Hide() end
        for i, entry in ipairs(gatherRoutes) do
            local button = self.gatherRouteChoices[i]
            if not button then
                button = makeButton(self.gatherRouteChild, "", 235, 23, function(b)
                    if b.mapID then
                        WP.activeFarmRoute = b.routeEntry
                        if WP.mapOverlayHost then WP.mapOverlayHost:Show() end
                        if b.routeEntry and b.routeEntry.available == false then
                            WP.mapRoutesVisible = true
                        else
                            WP:SetGatheringRoute(b.routeEntry, WP.selectedProfession)
                        end
                        if C_Map and C_Map.OpenWorldMap then pcall(C_Map.OpenWorldMap, b.mapID)
                        elseif SetMapByID then if ToggleWorldMap then ToggleWorldMap() end; pcall(SetMapByID, b.mapID) end
                        if WP.attachMapOverlay then WP.attachMapOverlay() end
                    end
                end)
                button:SetParent(self.gatherRouteChild)
                self.gatherRouteChoices[i] = button
            end
            button:SetPoint("TOPLEFT", 0, -(i - 1) * 26)
            button:SetWidth(math.max(160,(self.gatherRouteChild:GetWidth() or 190)-4))
            local factionTag = entry.faction and (" [" .. entry.faction .. "]") or ""
            button:SetText(entry.zone .. "  |  " .. (entry.item or entry.bracket or "Gathering route") .. factionTag)
            button.zoneName, button.mapID, button.routeEntry = entry.zone, entry.mapID, entry
            button:Show()
        end
        if self.gatherRouteChild then self.gatherRouteChild:SetHeight(math.max(self.gatherRouteScroll:GetHeight() or 1, #gatherRoutes * 26)) end
        self.dashboardFooter:SetText("GUIDE DATA  Profession leveling steps  |  FIELD ROUTES  Imported waypoint guides")
    else
        self.professionTitle:SetText("Select a profession guide")
        self.skillLabel:SetText("No profession scanned")
        self.dashboardProgress:SetMinMaxValues(0, 1)
        self.dashboardProgress:SetValue(0)
        self.zoneButton:Hide()
        for _, button in ipairs(self.zoneChoiceButtons or {}) do button:Hide() end
        self.guideStepTitle:SetText("Open a guide from the library")
        self.guideZone:SetText("Your tracked skill progress updates when the game reports it.")
        self.detailText:SetText("This window is the home for profession guides, gathering routes, the route arrow and the tracker.")
        self.reagentText:SetText("Select a profession to see its planned materials and bag counts.")
        self.reagentHeading:Show()
        self.reagentScroll:Show()
        self.reagentText:Show()
        self.routeHeading:Hide()
        self.gatherRouteScroll:Hide()
        self.dashboardFooter:SetText("No skill data detected yet.")
    end
    if self.UpdateOverview then self:UpdateOverview() end
    if self.farmingFrame and self.farmingFrame:IsShown() then self:UpdateFarmingGuides() end
    if self.UpdateGuideArrow then self:UpdateGuideArrow() end
end

function WP:UpdateTracker()
    if not self.trackerFrame then return end
    local p = self.selectedProfession and self.professions[self.selectedProfession]
    if not p and self.lastTrackedProfession then p = self.professions[self.lastTrackedProfession] end
    if not p then
        for name, learned in pairs(self.professions or {}) do
            p = learned
            self.lastTrackedProfession = name
            break
        end
    end
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
        local detail = (guide.title or "Current step") .. "\n" .. (guide.zone or "Route") .. "  target " .. tostring(guide.target or 300) .. herbs
        self.trackerFrame.activity:SetText(detail)
    elseif guide.status == "complete" then
        self.trackerFrame.activity:SetText("Guide complete: " .. p.name .. " " .. tostring(guide.target or 300) .. ".")
    else
        self.trackerFrame.activity:SetText(guide.text or "No route is bundled for this profession yet.")
    end
end

function WP:OpenMainWindow()
    if not self.mainFrame then self:CreateUI() end
    self.mainFrame:Show()
end

function WP:OpenShoppingList()
    local skillUp = self.SkillUp
    if skillUp and type(skillUp.OpenShoppingList) == "function" then
        skillUp.OpenShoppingList()
    else
        self:Print("The guide notes window is not ready yet. Try /reload, then /wp shopping.")
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







