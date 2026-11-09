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
    local route = self:GetGuideRoute(self.selectedProfession)
    if not route then return end

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

    for _, step in ipairs(route.steps or {}) do
        if step.mapID == mapID and type(step.x) == "number" and type(step.y) == "number" then
            addPath({ { step.x, step.y } }, step.title or step.zone, color)
        end
        for mapName, alternative in pairs(step.mapRoutes or {}) do
            if alternative.mapID == mapID then
                addPath(alternative.points, (step.title or step.zone or "Guide") .. " - " .. mapName, color)
            end
        end
    end

    local faction = UnitFactionGroup and UnitFactionGroup("player")
    for _, farm in ipairs(route.farmRoutes or {}) do
        if farm.mapID == mapID and (not farm.faction or not faction or farm.faction == faction) then
            local kindColor = palette[professionName] or color
            local label = farm.name or professionName .. " farming route"
            if farm.skill and farm.skill > 0 then label = label .. " (skill " .. farm.skill .. "+)" end
            addPath(farm.points, label, kindColor)
        end
    end

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
    local mapID = state and state.mapID
    if not mapID then
        self:Print("Select a gathering guide with map data first.")
        return
    end
    self.mapRoutesVisible = true
    if C_Map and C_Map.OpenWorldMap then
        C_Map.OpenWorldMap(mapID)
    elseif ToggleWorldMap then
        ToggleWorldMap()
    end
    self.mapOverlayHost:Show()
    if self.attachMapOverlay then self.attachMapOverlay() end
end

