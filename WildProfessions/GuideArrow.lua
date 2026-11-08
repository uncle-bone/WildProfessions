local _, WP = ...

local function safeMapInfo(mapID)
    if not (C_Map and type(C_Map.GetMapInfo) == "function") then return nil end
    local ok, info = pcall(C_Map.GetMapInfo, mapID)
    if ok and type(info) == "table" then return info end
end

local function isPlayerOnMap(targetMapID)
    if not targetMapID or not (C_Map and type(C_Map.GetBestMapForUnit) == "function") then return false end
    local ok, currentMapID = pcall(C_Map.GetBestMapForUnit, "player")
    if not ok or not currentMapID then return false end
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
    if not (C_Map and type(C_Map.GetPlayerMapPosition) == "function") then return nil end
    local ok, pos = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
    if not ok or not pos then return nil end
    if type(pos.GetXY) == "function" then
        local x, y = pos:GetXY()
        if type(x) == "number" and type(y) == "number" then return x, y end
    end
    if type(pos.x) == "number" and type(pos.y) == "number" then return pos.x, pos.y end
    return nil
end

function WP:InitializeGuideArrow()
    if self.guideArrow then return end
    local frame = CreateFrame("Frame", "WildProfessionsGuideArrow", UIParent, "BackdropTemplate")
    frame:SetSize(250, 92)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        frame:SetBackdropColor(0.02, 0.03, 0.05, 0.92)
    end

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
    frame.arrow:SetSize(38, 38)
    frame.arrow:SetPoint("LEFT", 12, 0)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 58, -12)
    frame.title:SetWidth(178)
    frame.title:SetJustifyH("LEFT")

    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.subtitle:SetPoint("TOPLEFT", 58, -34)
    frame.subtitle:SetWidth(178)
    frame.subtitle:SetJustifyH("LEFT")

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.hint:SetPoint("TOPLEFT", 58, -58)
    frame.hint:SetWidth(178)
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
        frame:Hide()
        return
    end
    frame:Show()

    if state.status == "complete" then
        frame.title:SetText(state.title)
        frame.subtitle:SetText("Herbalism 300 / 300")
        frame.hint:SetText("Use /wp to choose another profession.")
        frame.arrow:SetRotation(0)
        return
    end

    frame.title:SetText(state.title or "Profession guide")
    frame.subtitle:SetText((state.zone or "Route") .. "  ·  " .. tostring(state.skill or 0) .. " → " .. tostring(state.target or 300))

    local onMap = isPlayerOnMap(state.mapID)
    local px, py = onMap and playerPosition(state.mapID) or nil
    if type(px) == "number" and type(py) == "number" and type(state.x) == "number" and type(state.y) == "number" then
        local dx = state.x / 100 - px
        local dy = py - state.y / 100
        local angle = math.atan2 and math.atan2(dx, dy) or 0
        frame.arrow:SetRotation(angle)
        frame.hint:SetText("Follow arrow to approximate route area; use Find Herbs for live nodes.")
    else
        frame.arrow:SetRotation(0)
        frame.hint:SetText("Travel to the route zone. /wp guide hides or shows this arrow.")
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
