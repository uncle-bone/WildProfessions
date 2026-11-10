local _, WP = ...

local function safeMapInfo(mapID)
    if not (C_Map and type(C_Map.GetMapInfo) == "function") then return nil end
    local ok, info = pcall(C_Map.GetMapInfo, mapID)
    if ok and type(info) == "table" then return info end
end

local function legacyCurrentMapID()
    if type(GetCurrentMapAreaID) == "function" then
        local ok, id = pcall(GetCurrentMapAreaID)
        if ok and type(id) == "number" and id > 0 then return id end
    end
end

local function isPlayerOnMap(targetMapID)
    if not targetMapID then return false end
    local currentMapID
    if C_Map and type(C_Map.GetBestMapForUnit) == "function" then
        local ok, id = pcall(C_Map.GetBestMapForUnit, "player")
        if ok then currentMapID = id end
    end
    currentMapID = currentMapID or legacyCurrentMapID()
    if not currentMapID then return false end
    local cursor = currentMapID
    for _ = 1, 12 do
        if cursor == targetMapID then return true end
        local info = safeMapInfo(cursor)
        if not info or not info.parentMapID or info.parentMapID == 0 then break end
        cursor = info.parentMapID
    end
    return false
end

local function playerPosition(mapID)
    if C_Map and type(C_Map.GetPlayerMapPosition) == "function" then
        local ok, pos = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
        if ok and pos then
            if type(pos.GetXY) == "function" then
                local x, y = pos:GetXY()
                if type(x) == "number" and type(y) == "number" then return x, y end
            end
            if type(pos.x) == "number" and type(pos.y) == "number" then return pos.x, pos.y end
        end
    end
    -- Forever's classic map APIs expose coordinates only for the currently viewed map.
    -- Use them when that map matches the route, with no dependency on a retail-only C_Map call.
    if legacyCurrentMapID() == mapID and type(GetPlayerMapPosition) == "function" then
        local ok, x, y = pcall(GetPlayerMapPosition, "player")
        if ok and type(x) == "number" and type(y) == "number" and (x > 0 or y > 0) then return x, y end
    end
    return nil
end

local function openGuideMap(mapID)
    if not mapID then return end
    if C_Map and type(C_Map.OpenWorldMap) == "function" then
        local ok = pcall(C_Map.OpenWorldMap, mapID)
        if ok then return end
    end
    if ToggleWorldMap then ToggleWorldMap() end
    if type(SetMapByID) == "function" then pcall(SetMapByID, mapID) end
end

local function bearingText(dx, dy)
    local radians = math.atan2 and math.atan2(dx, dy) or math.atan(dx / (dy == 0 and 0.000001 or dy))
    if dy < 0 then radians = radians + math.pi end
    local degrees = (math.deg(radians) + 360) % 360
    local labels = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }
    local index = math.floor((degrees + 22.5) / 45) % 8 + 1
    return labels[index]
end

function WP:InitializeGuideArrow()
    if self.guideArrow then return end
    local frame = CreateFrame("Frame", "WildProfessionsGuideArrow", UIParent, "BackdropTemplate")
    frame:SetSize(290, 106)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetScript("OnMouseUp", function() local state=WP:GetCurrentGuideState(); if state and state.mapID then openGuideMap(state.mapID) elseif ToggleWorldMap then ToggleWorldMap() end end)
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        frame:SetBackdropColor(0.025, 0.035, 0.06, 0.96)
        frame:SetBackdropBorderColor(0.30, 0.45, 0.68, 1)
    end
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(0.98, 0.61, 0.20, 1)
    accent:SetHeight(2)
    accent:SetPoint("TOPLEFT", 6, -6)
    accent:SetPoint("TOPRIGHT", -6, -6)

    local point = self.db.settings.guideArrowPoint
    if type(point) == "table" and type(point.point) == "string" then
        frame:SetPoint(point.point, UIParent, point.relativePoint or point.point, tonumber(point.x) or 0, tonumber(point.y) or 140)
    else
        frame:SetPoint("TOP", UIParent, "TOP", 0, -145)
    end
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(f) if not WP.db.settings.guideArrowLocked then f:StartMoving() end end)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local p, _, rp, x, y = f:GetPoint(1)
        WP.db.settings.guideArrowPoint = { point = p, relativePoint = rp, x = x, y = y }
    end)

    frame.arrow = frame:CreateTexture(nil, "ARTWORK")
    frame.arrow:SetTexture("Interface\\Minimap\\MinimapArrow")
    frame.arrow:SetSize(48, 48)
    frame.arrow:SetPoint("LEFT", 10, 2)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 58, -12)
    frame.title:SetWidth(208)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetTextColor(0.38, 0.72, 1.0)

    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.subtitle:SetPoint("TOPLEFT", 58, -34)
    frame.subtitle:SetWidth(208)
    frame.subtitle:SetJustifyH("LEFT")

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.hint:SetPoint("TOPLEFT", 58, -58)
    frame.hint:SetWidth(208)
    frame.hint:SetHeight(38)
    frame.hint:SetJustifyV("TOP")
    frame.hint:SetJustifyH("LEFT")

    frame.elapsed = 0
    frame:SetScript("OnUpdate", function(f, elapsed)
        f.elapsed = f.elapsed + elapsed
        if f.elapsed >= 0.75 then
            f.elapsed = 0
            WP:UpdateGuideArrow()
        end
    end)
    self.guideArrow = frame
    if self.db.settings.guideVisible == false then frame:Hide() else frame:Show() end
    self:UpdateGuideArrow()
end

function WP:UpdateGuideArrow()
    local frame = self.guideArrow
    if not frame then return end
    if self.db and self.db.settings and self.db.settings.guideVisible == false then
        frame:Hide()
        return
    end
    local state = self:GetCurrentGuideState()
    if not state or (state.status ~= "active" and state.status ~= "trainer" and state.status ~= "complete") then
        if self.minimapRouteArrow then self.minimapRouteArrow:Hide() end
        frame:Hide()
        return
    end
    frame:Show()

    if state.status == "complete" then
        frame.title:SetText(state.title)
        frame.subtitle:SetText((state.route and state.route.name or "Profession") .. " " .. tostring(state.maxSkill or 300) .. " / " .. tostring(state.maxSkill or 300))
        frame.hint:SetText("Guide complete. Click here to open the route map.")
        frame.arrow:SetRotation(0)
        return
    end

    local minimapArrow = self.minimapRouteArrow
    if minimapArrow then minimapArrow:Hide() end

    frame.title:SetText(state.title or "Profession guide")
    frame.subtitle:SetText((state.zone or "Route") .. "  |  " .. tostring(state.skill or 0) .. " -> " .. tostring(state.target or 300))

    local onMap = isPlayerOnMap(state.mapID)
    local px, py
    if onMap then px, py = playerPosition(state.mapID) end
    local targetX, targetY = state.x, state.y
    local targetLabel = "route area"
    if type(px) == "number" and type(py) == "number" and type(state.routePoints) == "table" and #state.routePoints > 0 then
        local best, bestDistance = 1, math.huge
        for i, point in ipairs(state.routePoints) do local dx,dy=point[1]/100-px,point[2]/100-py;local dist=dx*dx+dy*dy;if dist<bestDistance then best,bestDistance=i,dist end end
        local targetIndex = best
        local nearest = state.routePoints[best]
        if bestDistance < 0.000012 then targetIndex = math.min(best + 1, #state.routePoints) end
        local nextPoint=state.routePoints[targetIndex] or nearest
        targetX,targetY=nextPoint[1],nextPoint[2]
        targetLabel = string.format("waypoint %d/%d", targetIndex, #state.routePoints)
    end
    if type(px) == "number" and type(py) == "number" and type(targetX) == "number" and type(targetY) == "number" then
        local dx = targetX / 100 - px
        local dy = py - targetY / 100
        local angle = math.atan2 and math.atan2(dx, dy) or math.atan(dx / (dy == 0 and 0.000001 or dy))
        if dy < 0 then angle = angle + math.pi end
        local yards = math.floor(math.sqrt(dx * dx + dy * dy) * 10000 + 0.5)
        frame.arrow:SetRotation(angle)
        if Minimap then
            if not self.minimapRouteArrow then
                local marker = CreateFrame("Frame", "WildProfessionsMinimapRouteArrow", Minimap)
                marker:SetSize(24, 24)
                marker:SetFrameLevel((Minimap.GetFrameLevel and Minimap:GetFrameLevel() or 1) + 8)
                marker.icon = marker:CreateTexture(nil, "OVERLAY")
                marker.icon:SetAllPoints()
                marker.icon:SetTexture("Interface\\Minimap\\MinimapArrow")
                marker.icon:SetVertexColor(0.98, 0.61, 0.20, 1)
                self.minimapRouteArrow = marker
            end
            local marker = self.minimapRouteArrow
            local radius = (Minimap:GetWidth() or 140) * 0.43
            local distance = math.sqrt(dx * dx + dy * dy)
            local scale = math.min(radius, distance * 3500) / math.max(distance, 0.0001)
            local ox, oy = dx * scale, dy * scale
            marker:ClearAllPoints()
            marker:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
            marker.icon:SetRotation(angle)
            marker:SetScript("OnEnter", function(target)
                GameTooltip:SetOwner(target, "ANCHOR_LEFT")
                GameTooltip:SetText(string.format("%s - %d yd", targetLabel, yards or 0), 0.98, 0.61, 0.20)
                GameTooltip:Show()
            end)
            marker:SetScript("OnLeave", function() GameTooltip:Hide() end)
            marker:Show()
        end
        frame.hint:SetText(string.format("%s  |  %s  |  %d yd\nFollow the line on the world map; tracking reveals live nodes.", targetLabel, bearingText(dx, dy), yards))
    else
        frame.arrow:SetRotation(0)
        if self.minimapRouteArrow then self.minimapRouteArrow:Hide() end
        frame.hint:SetText((state.zone and ("Travel to " .. state.zone .. ". ") or "Travel to the route area. ") .. "No local bearing until you enter the zone. Click to open the route map.")
    end
end

function WP:ToggleGuideArrow()
    if not self.guideArrow then self:InitializeGuideArrow() end
    if self.guideArrow:IsShown() then
        self.guideArrow:Hide()
        self.db.settings.guideVisible = false
    else
        self.db.settings.guideVisible = true
        self.guideArrow:Show()
        self:UpdateGuideArrow()
    end
end


