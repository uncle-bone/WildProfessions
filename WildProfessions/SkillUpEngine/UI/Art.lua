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
	local ok, frame = pcall(CreateFrame, "Frame", name, UIParent, "PortraitFrameTemplate")
	if not ok or not frame then
		frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
		frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, edgeSize = 14, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
		frame:SetBackdropColor(0.025, 0.035, 0.06, 0.99)
		frame:SetBackdropBorderColor(0.30, 0.45, 0.68, 1)
	end
	frame:SetSize(width, height)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)

	frame.windowTitle = frame.TitleContainer and frame.TitleContainer.TitleText or frame.TitleText
	if not frame.windowTitle then
		frame.windowTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		frame.windowTitle:SetPoint("TOP", 0, -8)
	end
	frame.windowTitle:SetText(title or "WildProfessions")
	frame.SetTitle = function(self, text) self.windowTitle:SetText(text or "WildProfessions") end

	local portrait = frame.PortraitContainer and frame.PortraitContainer.portrait or frame.portrait
	if portrait then
		portrait:SetTexture("Interface\\Icons\\Trade_Herbalism")
		portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		frame.windowIcon = portrait
	else
		local icon = frame:CreateTexture(nil, "ARTWORK")
		icon:SetSize(40, 40)
		icon:SetPoint("TOPLEFT", 13, -20)
		icon:SetTexture("Interface\\Icons\\Trade_Herbalism")
		frame.windowIcon = icon
	end
	frame.GetPortrait = function(self) return self.windowIcon end

	local close = frame.CloseButton
	if not close then
		close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", -2, -2)
	end
	close:SetScript("OnClick", function() frame:Hide() end)
	frame.windowClose = close

	-- A transparent drag strip preserves the portrait frame art while keeping the
	-- familiar WildSpark drag behavior.
	local header = CreateFrame("Frame", nil, frame)
	header:SetPoint("TOPLEFT", 58, -5)
	header:SetSize(math.max(200, width - 100), 48)
	header:EnableMouse(true)
	header:RegisterForDrag("LeftButton")
	header:SetScript("OnDragStart", function() frame:StartMoving() end)
	header:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
	frame.header = header

	frame:Hide()
	tinsert(UISpecialFrames, name)
	return frame
end
