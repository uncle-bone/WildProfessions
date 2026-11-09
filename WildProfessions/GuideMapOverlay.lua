local _, WP = ...

local function clear(host)
    for _, mark in ipairs(host.routeMarks or {}) do mark:Hide() end
    host.routeMarks = {}
end

local function makeMark(parent, size, r, g, b)
    local texture = parent:CreateTexture(nil, "OVERLAY")
    texture:SetTexture("Interface/Buttons/WHITE8X8")
    texture:SetSize(size, size)
    texture:SetVertexColor(r, g, b, 0.95)
    return texture
end

local function visibleMapID()
    if WorldMapFrame and type(WorldMapFrame.GetMapID) == "function" then
        local ok, id = pcall(WorldMapFrame.GetMapID, WorldMapFrame)
        if ok then return id end
    end
    if WorldMapFrame and type(WorldMapFrame.mapID) == "number" then return WorldMapFrame.mapID end
    if type(GetCurrentMapAreaID) == "function" then
        local ok, id = pcall(GetCurrentMapAreaID)
        if ok and type(id) == "number" and id > 0 then return id end
    end
    if C_Map and type(C_Map.GetBestMapForUnit) == "function" then
        local ok, id = pcall(C_Map.GetBestMapForUnit, "player")
        if ok and type(id) == "number" then return id end
    end
end

local function openMap(mapID)
    if C_Map and type(C_Map.OpenWorldMap) == "function" then
        local ok = pcall(C_Map.OpenWorldMap, mapID)
        if ok then return end
    end
    if ToggleWorldMap then ToggleWorldMap() end
    if type(SetMapByID) == "function" then pcall(SetMapByID, mapID) end
end

local function normalizedPoints(points)
    local result = {}
    for _, point in ipairs(points or {}) do
        if type(point[1]) == "number" and type(point[2]) == "number" then
            result[#result + 1] = { x = point[1] / 100, y = point[2] / 100 }
        end
    end
    return result
end

local function drawPath(host, points, label, color)
    if #points == 0 then return end
    local width, height = host:GetWidth(), host:GetHeight()
    for i = 1, #points - 1 do
        local a, b = points[i], points[i + 1]
        local dx, dy = (b.x - a.x) * width, (b.y - a.y) * height
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then
            local line = host:CreateTexture(nil, "ARTWORK")
            line:SetTexture("Interface/Buttons/WHITE8X8")
            line:SetVertexColor(color[1], color[2], color[3], 0.85)
            line:SetSize(length, 3)
            line:SetPoint("CENTER", host, "TOPLEFT", ((a.x + b.x) / 2) * width, -((a.y + b.y) / 2) * height)
            line:SetRotation(math.atan2 and math.atan2(-dy, dx) or 0)
            line:Show()
            host.routeMarks[#host.routeMarks + 1] = line
        end
    end
    for _, point in ipairs(points) do
        local pin = CreateFrame("Frame", nil, host)
        pin:SetSize(18, 18)
        pin:SetPoint("CENTER", host, "TOPLEFT", point.x * width, -point.y * height)
        pin:EnableMouse(true)
        pin.icon = makeMark(pin, 16, color[1], color[2], color[3])
        pin.icon:SetPoint("CENTER")
        pin.label = pin:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        pin.label:SetText("+")
        pin.label:SetPoint("CENTER", pin, "CENTER")
        pin.label:SetTextColor(0, 0, 0, 1)
        pin:SetScript("OnEnter", function(frame)
            if GameTooltip then
                GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
                GameTooltip:SetText(label or "Route waypoint", 1, 0.9, 0.5)
                GameTooltip:Show()
            end
        end)
        pin:SetScript("OnLeave", function()
            if GameTooltip then GameTooltip:Hide() end
        end)
        pin:Show()
        host.routeMarks[#host.routeMarks + 1] = pin
    end
end

function WP:RefreshMapOverlay()
    local host = self.mapOverlayHost
    if not host or self.mapRoutesVisible == false then return end
    clear(host)
    local mapID = visibleMapID()
    if not mapID then return end
    -- Atlas routes are standalone source records and must work even when their
    -- category is not the character's active skill-up profession.
    local selectedFarm = self.activeFarmRoute
    if selectedFarm then
        if selectedFarm.mapID == mapID then
            local routePalette = {
                Herbalism = { 0.15, 0.95, 0.35 }, Mining = { 1.0, 0.78, 0.15 },
                Skinning = { 0.92, 0.55, 0.22 }, Fishing = { 0.2, 0.7, 1.0 },
            }
            local color = routePalette[selectedFarm.category] or { 0.2, 0.8, 0.95 }
            drawPath(host, normalizedPoints(selectedFarm.points), tostring(selectedFarm.item or selectedFarm.name or "Farming route"), color)
        end
        return
    end
    local selectedProfession = self.selectedProfession and self.professions[self.selectedProfession]
    if not selectedProfession and self.selectedProfession then
        selectedProfession = { name = self.selectedProfession, skill = 0, maxSkill = 300 }
    end
    local route = self:GetGuideRoute(selectedProfession)
    if not route then return end
    local guideState = selectedProfession and self:GetGuideState(selectedProfession) or nil

    local paths, signatures = {}, {}
    local palette = {
        Herbalism = { 0.15, 0.95, 0.35 },
        Mining = { 1.0, 0.78, 0.15 },
        Skinning = { 0.92, 0.55, 0.22 },
        Fishing = { 0.2, 0.7, 1.0 },
    }
    local professionName = route.name or "Herbalism"
    local color = palette[professionName] or palette.Herbalism
    local function addPath(raw, label, pathColor)
        local points = normalizedPoints(raw)
        if #points == 0 then return end
        local parts = {}
        for _, point in ipairs(points) do
            parts[#parts + 1] = string.format("%.4f,%.4f", point.x, point.y)
        end
        local signature = table.concat(parts, ";")
        local existing = signatures[signature]
        if existing then
            if label and label ~= "" and not existing.label:find(label, 1, true) then
                existing.label = existing.label .. " / " .. label
            end
            return
        end
        local entry = { points = points, label = label, color = pathColor or color }
        paths[#paths + 1] = entry
        signatures[signature] = entry
    end

    -- A clicked farming atlas entry is a single route request. Do not paint every
    -- resource track for that zone on top of the selected route.
    for _, step in ipairs(route.steps or {}) do
        if step.mapID == mapID and type(step.x) == "number" and type(step.y) == "number" then
            addPath({ { step.x, step.y } }, step.title or step.zone, color)
        end
        for mapName, alternative in pairs(step.mapRoutes or {}) do
            -- Show every zone option on its own map, independent of the saved selection.
            if alternative.mapID == mapID then
                addPath(alternative.points, (step.title or step.zone or "Guide") .. " - " .. mapName, color)
            end
        end
    end

    if guideState and guideState.mapID == mapID and guideState.routePoints then
        addPath(guideState.routePoints, (guideState.title or route.name or "Guide") .. " - " .. (guideState.selectedZone or guideState.zone or "route"), color)
    end

    for _, farm in ipairs(route.farmRoutes or {}) do
        if farm.mapID == mapID then
            local kindColor = palette[professionName] or color
            local label = farm.name or professionName .. " farming route"
            if farm.skill and farm.skill > 0 then label = label .. " (skill " .. farm.skill .. "+)" end
            addPath(farm.points, label, kindColor)
        end
    end

    -- The map is a route view, not a resource heatmap. Farming rows are selected
    -- explicitly from the Farming Guides atlas; keep the leveling guide overlay
    -- limited to its selected route and step.

    for _, path in ipairs(paths) do
        drawPath(host, path.points, path.label, path.color)
    end
end

function WP:InitializeMapOverlay()
    if self.mapOverlayHost then return end
    local frame = CreateFrame("Frame", "WildProfessionsMapOverlay", UIParent)
    frame.routeMarks = {}
    self.mapOverlayHost = frame

    local function attach()
        if not WorldMapFrame then return end
        local child = (WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child)
            or WorldMapFrame.ScrollContainer or WorldMapFrame
        frame:SetFrameStrata("HIGH")
        frame:ClearAllPoints()
        frame:SetParent(child)
        frame:SetAllPoints(child)
        frame:SetFrameLevel((child:GetFrameLevel() or 1) + 50)
        self:RefreshMapOverlay()
    end
    self.attachMapOverlay = attach

    if WorldMapFrame then
        WorldMapFrame:HookScript("OnShow", attach)
        if WorldMapFrame.ScrollContainer then
            WorldMapFrame.ScrollContainer:HookScript("OnSizeChanged", function()
                if WorldMapFrame:IsShown() then attach() end
            end)
        end
    end

    local events = CreateFrame("Frame")
    local elapsed, lastMap, lastProfession = 0, nil, nil
    events:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        if elapsed < 0.35 then return end
        elapsed = 0
        if WorldMapFrame and WorldMapFrame:IsShown() then
            local mapID = visibleMapID()
            local selected = self.selectedProfession
            if mapID and (mapID ~= lastMap or selected ~= lastProfession) then
                lastMap, lastProfession = mapID, selected
                attach()
            end
        end
    end)
    frame:Hide()
end

function WP:ToggleMapRoutes()
    if not self.mapOverlayHost then self:InitializeMapOverlay() end
    if self.mapRoutesVisible then
        self.mapRoutesVisible = false
        self.mapOverlayHost:Hide()
        self:Print("Map route overlay hidden.")
        return
    end
    local state = self:GetCurrentGuideState()
    local mapID = visibleMapID()
    if not (WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()) then
        mapID = state and state.mapID
    end
    if not mapID then
        self:Print("Select a gathering guide with map data first.")
        return
    end
    self.mapRoutesVisible = true
    openMap(mapID)
    self.mapOverlayHost:Show()
    if self.attachMapOverlay then self.attachMapOverlay() end
end

