---@type string, SkillUpNamespace
local addonName, outer = ...
local ns = outer.SkillUp or {}
outer.SkillUp = ns
local L = ns.L
local ICON = "Interface\\AddOns\\" .. addonName .. "\\media\\Icon"
local frame, body, scroll, copyWindow, copyEdit, shown, footer, summary, tripButton, copyButton, copyText

local function Name(itemID)
	local name = C_Item.GetItemNameByID(itemID)
	if not name then
		C_Item.RequestLoadItemDataByID(itemID)
		return string.format(L["item %d"], itemID)
	end
	return name
end

local function Copy(text)
	if not copyWindow then
		copyWindow = CreateFrame("Frame", addonName .. "ShoppingCopy", UIParent, "PortraitFrameTemplate")
		table.insert(UISpecialFrames, addonName .. "ShoppingCopy")
		copyWindow:SetSize(460, 380)
		copyWindow:SetPoint("CENTER")
		copyWindow:SetFrameStrata("DIALOG")
		copyWindow:SetToplevel(true)
		copyWindow:SetClampedToScreen(true)
		copyWindow:SetMovable(true)
		copyWindow:EnableMouse(true)
		copyWindow:RegisterForDrag("LeftButton")
		copyWindow:SetScript("OnDragStart", copyWindow.StartMoving)
		copyWindow:SetScript("OnDragStop", copyWindow.StopMovingOrSizing)
		copyWindow:SetTitle(L["Shopping list"])
		ns.Art.Icon(copyWindow:GetPortrait(), ICON, 62)
		local hint = copyWindow:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		hint:SetPoint("TOPLEFT", 70, -32)
		hint:SetPoint("RIGHT", -16, 0)
		hint:SetJustifyH("LEFT")
		hint:SetText(L["The text is selected. Press Ctrl+C (Cmd+C on a Mac) to copy it."])
		local inset = CreateFrame("Frame", nil, copyWindow, "InsetFrameTemplate")
		inset:SetPoint("TOPLEFT", 10, -64)
		inset:SetPoint("BOTTOMRIGHT", -10, 10)
		local sf = CreateFrame("ScrollFrame", nil, inset, "ScrollFrameTemplate")
		sf:SetPoint("TOPLEFT", 8, -8)
		sf:SetPoint("BOTTOMRIGHT", -28, 8)
		copyEdit = CreateFrame("EditBox", nil, sf)
		copyEdit:SetMultiLine(true)
		copyEdit:SetAutoFocus(false)
		copyEdit:SetFontObject("ChatFontNormal")
		copyEdit:SetWidth(390)
		copyEdit:SetMaxLetters(0)
		copyEdit:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				self:SetText(shown)
				self:SetFocus()
				self:HighlightText()
			end
		end)
		copyEdit:SetScript("OnEditFocusGained", copyEdit.HighlightText)
		copyEdit:SetScript("OnEscapePressed", function()
			copyWindow:Hide()
		end)
		sf:SetScrollChild(copyEdit)
		sf:SetScript("OnSizeChanged", function(frame)
			copyEdit:SetWidth(math.max(180, frame:GetWidth() - 6))
		end)
	end
	shown = text
	copyEdit:SetText(text)
	copyWindow:Show()
	copyEdit:SetFocus()
	copyEdit:HighlightText()
end

local function Refresh()
	if not frame or not frame:IsShown() then
		return
	end
	for _, child in ipairs({ body:GetChildren() }) do
		child:Hide()
		child:SetParent(nil)
	end
	local wp = _G.WildProfessions
	if frame and frame.SetTitle then frame:SetTitle("Guide shopping notes") end
	if copyButton then copyButton:SetText("Copy guide notes") end
	if not wp or type(wp.GetGuideRoute) ~= "function" or type(wp.GetGuideState) ~= "function" then
		summary:SetText("WildProfessions guide data is not ready")
		local text = body:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		text:SetPoint("TOPLEFT", 8, -10)
		text:SetWidth(math.max(180, body:GetWidth() - 20))
		text:SetWordWrap(true)
		text:SetText("SkillUp recipe totals are not used as WildProfessions guide data. Open the window again when WildProfessions finishes loading.")
		body:SetHeight(80)
		footer:SetText("Guide shopping data unavailable")
		if tripButton then tripButton:Hide() end
		return
	end
	if wp then
		local guideName = wp.selectedProfession
		local learned = guideName and wp.professions and wp.professions[guideName]
		local guideProfession = learned or (guideName and { name = guideName, skill = 0, maxSkill = 300 })
		local route = guideProfession and wp:GetGuideRoute(guideProfession)
		local state = guideProfession and wp:GetGuideState(guideProfession)
		local lines = {}
		local professionName = route and route.name or guideName or "No guide selected"
		summary:SetText("WoW-Professions guide notes for " .. professionName)
		if not route or not state or state.status == "route-needed" then
			lines[#lines + 1] = "No bundled WoW-Professions guide data is available for this profession yet."
		else
			if learned then
				lines[#lines + 1] = string.format("Current skill: %d/%d", learned.skill or 0, learned.maxSkill or 300)
			elseif route.skills then
				for _, skillName in ipairs({ "Fishing", "Cooking" }) do
					local data = route.skills[skillName]
					if data then lines[#lines + 1] = string.format("%s: %d/%d", skillName, data.skill or 0, data.maxSkill or 300) end
				end
			else
				lines[#lines + 1] = "Guide preview; the live tracker follows professions your character knows."
			end
			if state.activeTasks then
				for _, skillName in ipairs({ "Fishing", "Cooking" }) do
					local task = state.activeTasks[skillName]
					local data = route.skills and route.skills[skillName] or {}
					lines[#lines + 1] = task and string.format("%s: %s (%d -> %d)", skillName, task.title or "current section", task.skill or 0, task.target or 300) or string.format("%s: complete (%d/300)", skillName, data.skill or 0)
				end
			end
			for _, step in ipairs(route.steps or {}) do
				local skill = step.skill and route.skills and route.skills[step.skill] and tonumber(route.skills[step.skill].skill)
					or (learned and tonumber(learned.skill)) or 0
				if skill < (tonumber(step.target) or math.huge) then
					lines[#lines + 1] = ""
					lines[#lines + 1] = (step.title or "Guide step") .. (step.zone and (" - " .. step.zone) or "")
                    if step.recipeOptions then lines[#lines + 1] = "Choose one recipe branch: " .. step.recipeOptions end
                    if step.estimate then lines[#lines + 1] = "Estimated only: " .. step.estimate end
					local materials = step.materials or step.materialSummary
					if type(materials) == "string" and materials ~= "" then
						lines[#lines + 1] = materials
					elseif type(materials) == "table" then
						for _, item in ipairs(materials) do
							if type(item) == "table" then
								lines[#lines + 1] = tostring(item.name or item.item or item.itemID or "Material") .. (item.count and (" x" .. tostring(item.count)) or "")
							else
								lines[#lines + 1] = tostring(item)
							end
						end
					elseif step.instructions and step.instructions ~= "" then
						lines[#lines + 1] = step.instructions
					end
					if step.carryForward and step.carryForward ~= "" then
						lines[#lines + 1] = "Carry forward: " .. step.carryForward
					end
				end
			end
			lines[#lines + 1] = ""
			lines[#lines + 1] = "Quantities and alternative recipe totals are shown only when recorded in the source guide data. Preserve saved intermediates; this view does not infer SkillUp recipe totals."
		end
		copyText = table.concat(lines, "\n")
		local top = -10
		for _, line in ipairs(lines) do
			local text = body:CreateFontString(nil, "ARTWORK", line == "" and "GameFontNormalSmall" or "GameFontHighlight")
			text:SetPoint("TOPLEFT", 8, top)
		text:SetWidth(math.max(180, body:GetWidth() - 20))
			text:SetJustifyH("LEFT")
			text:SetWordWrap(true)
			text:SetText(line)
			top = top - (line == "" and 8 or 34)
		end
		body:SetHeight(math.max(1, -top + 20))
		footer:SetText("Guide notes only; exact item totals are incomplete where marked.")
		if tripButton then tripButton:Hide() end
		return
	end
	local lists = ns.ShoppingList()
	-- The window groups by source, not profession, so the header names every plan it is buying for.
	local plans = {}
	for _, list in ipairs(lists) do
		plans[#plans + 1] = string.format(L["%s to %d"], list.profession, list.target)
	end
	summary:SetText(#plans > 0 and string.format(L["Buying for %s"], table.concat(plans, ", ")) or "")
	local top, any, total, unpriced = -10, false, 0, 0
	local headings =
		{ gather = L["Gather"], vendor = L["Vendor"], auction = L["Auction house"], unknown = L["Unknown"] }
	for _, source in ipairs(ns.Model.SHOPPING_SOURCES) do
		local rows = {}
		for _, list in ipairs(lists) do
			for _, row in ipairs(list.items) do
				if row.source == source and row.missing > 0 then
					rows[#rows + 1] = { list = list, row = row }
				end
			end
		end
		if #rows > 0 then
			any = true
			local heading = body:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
			heading:SetPoint("TOPLEFT", 8, top)
			heading:SetText(headings[source])
			top = top - 28
			for _, entry in ipairs(rows) do
				local row = entry.row
				local item = CreateFrame("Frame", nil, body)
				item:SetPoint("TOPLEFT", 8, top)
				item:SetSize(math.max(300, body:GetWidth() - 16), 48)
				local icon = item:CreateTexture(nil, "ARTWORK")
				icon:SetSize(32, 32)
				icon:SetPoint("LEFT", 0, 0)
				local texture = C_Item.GetItemIconByID(row.itemID)
				if texture then
					icon:SetTexture(texture) -- art-ok: square item icons keep their native aspect.
				end
				local name = item:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 0)
				name:SetWidth(math.max(200, body:GetWidth() - 74))
				name:SetText(
					string.format(L["%s (%s to %d)"], Name(row.itemID), entry.list.profession, entry.list.target)
				)
				local alt = row.alt[1] and string.format(L["on %s"], row.alt[1].name) or ""
				local unit = row.price and ns.FormatNet(ns.Model.RoundMoney(row.price), false) or L["price unknown"]
				local cost = row.cost and ns.FormatNet(ns.Model.RoundMoney(row.cost), false) or "-"
				local detail = item:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
				detail:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 0)
				detail:SetWidth(math.max(200, body:GetWidth() - 74))
				detail:SetHeight(28)
				detail:SetWordWrap(true)
				detail:SetText(
					string.format(
						L["Need %d, have %d, missing %d  %s  %s each  %s"],
						row.need,
						row.have,
						row.missing,
						alt,
						unit,
						cost
					)
				)
				if row.cost then
					total = total + row.cost
				elseif row.missing > 0 then
					unpriced = unpriced + 1
				end
				top = top - 50
			end
		end
	end
	if not any then
		local empty = body:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		empty:SetPoint("CENTER")
		empty:SetText(#lists == 0 and L["No tracked profession"] or L["Nothing to buy"])
	end
	body:SetHeight(math.max(1, -top + 20))
	footer:SetText(
		L["Total for priced items: "]
			.. ns.FormatNet(ns.Model.RoundMoney(total), false)
			.. (unpriced > 0 and string.format(L["  %d items have no price yet"], unpriced) or "")
	)
end

local function Create()
	if frame then
		return frame
	end
	frame = CreateFrame("Frame", addonName .. "ShoppingList", UIParent, "PortraitFrameTemplate")
	table.insert(UISpecialFrames, addonName .. "ShoppingList")
	frame:SetSize(620, 500)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetTitle(L["Shopping list"])
	ns.Art.Icon(frame:GetPortrait(), ICON, 62)
	-- Clear of the portrait, which overhangs the top-left corner, and above the list.
	summary = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	summary:SetPoint("TOPLEFT", 82, -36)
	summary:SetPoint("RIGHT", -16, 0)
	summary:SetJustifyH("LEFT")
	summary:SetHeight(28)
	local inset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	inset:SetPoint("TOPLEFT", 10, -70)
	inset:SetPoint("BOTTOMRIGHT", -10, 48)
	scroll = CreateFrame("ScrollFrame", nil, inset, "ScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 8, -8)
	scroll:SetPoint("BOTTOMRIGHT", -28, 8)
	body = CreateFrame("Frame", nil, scroll)
	body:SetWidth(550)
	scroll:SetScrollChild(body)
	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(frame, delta)
		local maximum = math.max(0, body:GetHeight() - frame:GetHeight())
		frame:SetVerticalScroll(math.max(0, math.min(maximum, frame:GetVerticalScroll() - delta * 52)))
	end)
	scroll:SetScript("OnSizeChanged", function(frame)
		body:SetWidth(math.max(300, frame:GetWidth() - 4))
	end)
	footer = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	footer:SetPoint("BOTTOMRIGHT", -16, 18)
	footer:SetJustifyH("RIGHT")
	footer:SetWidth(330)
	footer:SetHeight(30)
	footer:SetWordWrap(true)
	local copy = CreateFrame("Button", nil, frame, "SharedButtonSmallTemplate")
	copyButton = copy
	copy:SetSize(110, 24)
	copy:SetPoint("BOTTOMLEFT", 16, 14)
	copy:SetText(L["Copy list"])
	copy:SetScript("OnClick", function()
		Copy(copyText or ns.ShoppingText())
	end)
	local trip = CreateFrame("Button", nil, frame, "SharedButtonSmallTemplate")
	tripButton = trip
	trip:SetSize(130, 24)
	trip:SetPoint("LEFT", copy, "RIGHT", 8, 0)
	trip:SetText(L["Plan buy trip"])
	local api = ShortestPathForever and ShortestPathForever.API
	trip:SetEnabled(api and type(api.NavigateRoute) == "function")
	trip:SetScript("OnClick", function()
		ns.ShoppingTrip()
	end)
	trip:SetScript("OnEnter", function(self)
		if not self:IsEnabled() then
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip_SetTitle(GameTooltip, L["A buy trip needs Shortest Path Forever."])
			GameTooltip:Show()
		end
	end)
	trip:SetScript("OnLeave", GameTooltip_Hide)
	frame:SetScript("OnShow", Refresh)
	frame:Hide()
	return frame
end

local ready, enteredWorld, variablesLoaded, pendingOpen = false, false, false, false
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("VARIABLES_LOADED")
events:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		enteredWorld = true
	else
		variablesLoaded = true
	end
	if not (enteredWorld and variablesLoaded) or ready then
		return
	end
	ready = true
	C_Timer.After(0, function()
		Create()
		if pendingOpen then
			frame:Show()
			Refresh()
			pendingOpen = false
		end
	end)
end)

function ns.OpenShoppingList()
	if not ready then
		pendingOpen = true
		return
	end
	Create():Show()
	Refresh()
end
ns.WhenStale("shoppingList", Refresh)
