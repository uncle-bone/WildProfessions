local _, WP = ...
function WP:InitializeMinimapButton()
 if self.minimapButton then return end
 local b=CreateFrame("Button","WildProfessionsMinimapButton",Minimap,"BackdropTemplate")
 b:SetSize(32,32); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(8); b:RegisterForClicks("LeftButtonUp","RightButtonUp"); b:SetMovable(true); b:EnableMouse(true)
 b:SetPoint("TOPLEFT",Minimap,"TOPLEFT",-2,2)
 if b.SetBackdrop then b:SetBackdrop({bgFile="Interface/Buttons/WHITE8X8",edgeFile="Interface/Buttons/WHITE8X8",edgeSize=1});b:SetBackdropColor(0.08,0.12,0.08,0.95);b:SetBackdropBorderColor(0.8,0.65,0.2,1) end
 local icon=b:CreateTexture(nil,"ARTWORK");icon:SetTexture("Interface/Icons/INV_Misc_Herb_01");icon:SetSize(20,20);icon:SetPoint("CENTER");icon:SetTexCoord(0.08,0.92,0.08,0.92)
 local highlight=b:CreateTexture(nil,"HIGHLIGHT");highlight:SetTexture("Interface/Buttons/ButtonHilight-Square");highlight:SetBlendMode("ADD");highlight:SetAllPoints()
 local border=b:CreateTexture(nil,"OVERLAY"); border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); border:SetSize(54,54); border:SetPoint("TOPLEFT")
 b:SetScript("OnClick",function(_,button) if button=="RightButton" then WP:ToggleTracker() else WP:OpenMainWindow() end end)
 b:SetScript("OnEnter",function(self) GameTooltip:SetOwner(self,"ANCHOR_LEFT"); GameTooltip:AddLine("WildProfessions"); GameTooltip:AddLine("Left-click: open guide window",1,1,1); GameTooltip:AddLine("Right-click: toggle tracker",1,1,1); GameTooltip:AddLine("Drag to move",.7,.7,.7); GameTooltip:Show() end); b:SetScript("OnLeave",function() GameTooltip:Hide() end)
 b:RegisterForDrag("LeftButton"); b:SetScript("OnDragStart",function(self) self:StartMoving() end); b:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
 self.minimapButton=b
end
