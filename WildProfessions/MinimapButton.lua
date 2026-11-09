local _, WP = ...
function WP:InitializeMinimapButton()
 if self.minimapButton then return end
 local b=CreateFrame("Button","WildProfessionsMinimapButton",Minimap)
 b:SetSize(32,32); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(8); b:RegisterForClicks("LeftButtonUp","RightButtonUp"); b:SetMovable(true); b:EnableMouse(true)
 b:SetPoint("TOPLEFT",Minimap,"TOPLEFT",-2,2)
 local icon=b:CreateTexture(nil,"BACKGROUND"); icon:SetTexture("Interface\Icons\Trade_BlackSmithing"); icon:SetSize(20,20); icon:SetPoint("CENTER")
 local border=b:CreateTexture(nil,"OVERLAY"); border:SetTexture("Interface\Minimap\MiniMap-TrackingBorder"); border:SetSize(54,54); border:SetPoint("TOPLEFT")
 b:SetScript("OnClick",function(_,button) if button=="RightButton" then WP:ToggleTracker() else WP:ToggleDashboard() end end)
 b:SetScript("OnEnter",function(self) GameTooltip:SetOwner(self,"ANCHOR_LEFT"); GameTooltip:AddLine("WildProfessions"); GameTooltip:AddLine("Left-click: open guide window",1,1,1); GameTooltip:AddLine("Right-click: toggle tracker",1,1,1); GameTooltip:AddLine("Drag to move",.7,.7,.7); GameTooltip:Show() end); b:SetScript("OnLeave",function() GameTooltip:Hide() end)
 b:RegisterForDrag("LeftButton"); b:SetScript("OnDragStart",function(self) self:StartMoving() end); b:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
 self.minimapButton=b
end
