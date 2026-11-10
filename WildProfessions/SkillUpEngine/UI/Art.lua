---@type string, SkillUpNamespace
local _, outer = ...
local ns = outer.SkillUp or {}
outer.SkillUp = ns

-- Art at its native aspect (AGENTS.md: never stretch art): an atlas is sized from C_Texture.GetAtlasInfo, never
-- pulled to a box of another shape. Only nine-slice pieces, bars and fills stretch, by design.

---@class SkillUpArt
local Art = {}
ns.Art = Art

-- The atlas's width over its height; square when the client doesn't know it.
---@param atlas string
---@return number
local function Aspect(atlas)
	local info = C_Texture.GetAtlasInfo(atlas)
	if info and info.width > 0 and info.height > 0 then
		return info.width / info.height
	end
	return 1
end

-- `atlas` at the largest size inside `width` by `height` at its own aspect. The caller anchors it by one point.
---@param texture Texture
---@param atlas string
---@param width number
---@param height number
---@return number width
---@return number height
function Art.Fit(texture, atlas, width, height)
	texture:SetAtlas(atlas)
	local aspect = Aspect(atlas)
	local w, h = width, width / aspect
	if h > height then
		w, h = height * aspect, height
	end
	texture:SetSize(w, h)
	return w, h
end

-- `|A:atlas:height:width|a` with the width from the atlas's aspect.
---@param atlas string
---@param height number
---@return string
function Art.Markup(atlas, height)
	return ("|A:%s:%d:%d|a"):format(atlas, height, math.floor(height * Aspect(atlas) + 0.5))
end

-- A file icon, square as every one is, `size` across and whole: a texture that drew an atlas before keeps that
-- atlas's crop until it is reset.
---@param texture Texture
---@param file string|integer
---@param size number
function Art.Icon(texture, file, size)
	texture:SetTexCoord(0, 1, 0, 1)
	texture:SetTexture(file)
	texture:SetSize(size, size)
end

-- Addon-owned windows share the WildProfessions field-desk frame rather than the
-- legacy portrait panel used by the original planner.
function Art.Window(name, width, height, title)
	local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
	frame:SetSize(width, height)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, edgeSize = 14, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
	frame:SetBackdropColor(0.025, 0.035, 0.06, 0.99)
	frame:SetBackdropBorderColor(0.30, 0.45, 0.68, 1)
	local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	header:SetPoint("TOPLEFT", 6, -6)
	header:SetPoint("TOPRIGHT", -6, -6)
	header:SetHeight(48)
	header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
	header:SetBackdropColor(0.07, 0.10, 0.17, 1)
	local accent = header:CreateTexture(nil, "ARTWORK")
	accent:SetColorTexture(0.98, 0.61, 0.20, 1)
	accent:SetHeight(2)
	accent:SetPoint("BOTTOMLEFT")
	accent:SetPoint("BOTTOMRIGHT")
	local icon = header:CreateTexture(nil, "ARTWORK")
	icon:SetSize(30, 30)
	icon:SetPoint("LEFT", 12, 0)
	frame.windowIcon = icon
	local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	label:SetPoint("LEFT", icon, "RIGHT", 10, 0)
	label:SetPoint("RIGHT", -44, 0)
	label:SetJustifyH("LEFT")
	label:SetTextColor(0.94, 0.96, 1)
	frame.windowTitle = label
	frame.SetTitle = function(self, text) self.windowTitle:SetText(text or "WildProfessions") end
	frame.GetPortrait = function(self) return self.windowIcon end
	frame:SetTitle(title)
	local close = CreateFrame("Button", nil, header, "UIPanelCloseButton")
	close:SetSize(24, 24)
	close:SetPoint("RIGHT", -4, 0)
	close:SetScript("OnClick", function() frame:Hide() end)
	frame.windowClose = close
	header:EnableMouse(true)
	header:RegisterForDrag("LeftButton")
	header:SetScript("OnDragStart", function() frame:StartMoving() end)
	header:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
	frame.header = header
	return frame
end
