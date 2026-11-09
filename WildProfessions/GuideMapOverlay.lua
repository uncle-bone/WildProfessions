local _, WP = ...
local function clear(self) for _,v in ipairs(self.routeMarks or {}) do v:Hide() end end
local function makeMark(parent,texture,size,r,g,b)
 local t=parent:CreateTexture(nil,"OVERLAY");t:SetTexture(texture);t:SetSize(size,size);t:SetVertexColor(r,g,b,0.95);return t
end
local function visibleMapID()
 if WorldMapFrame and type(WorldMapFrame.GetMapID)=="function" then local ok,id=pcall(WorldMapFrame.GetMapID,WorldMapFrame);if ok then return id end end
end
function WP:RefreshMapOverlay()
 local host=self.mapOverlayHost; if not host then return end; clear(host)
 local id=visibleMapID(); if not id then return end
 local points={}
 for _,route in pairs(self.RouteData or {}) do
  for _,step in ipairs(route.steps or {}) do if step.mapID==id and type(step.x)=="number" and type(step.y)=="number" then points[#points+1]={x=step.x/100,y=step.y/100,label=step.title or step.zone} end end
 end
 table.sort(points,function(a,b) if a.y==b.y then return a.x<b.x end return a.y<b.y end)
 for i,pt in ipairs(points) do
  local pin=makeMark(host,"Interface\Minimap\Minimap-QuestArrow",18,0.1,0.95,0.35); pin:SetPoint("CENTER",host,"TOPLEFT",pt.x*host:GetWidth(),-pt.y*host:GetHeight()); pin:Show();host.routeMarks[#host.routeMarks+1]=pin
  local label=host:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");label:SetText(i);label:SetPoint("CENTER",pin,"CENTER");label:SetTextColor(1,1,1);label:Show();host.routeMarks[#host.routeMarks+1]=label
 end
end
function WP:InitializeMapOverlay()
 if self.mapOverlayHost then return end
 local frame=CreateFrame("Frame","WildProfessionsMapOverlay",UIParent);frame.routeMarks={};self.mapOverlayHost=frame
 local function attach()
  if not WorldMapFrame or not WorldMapFrame.ScrollContainer or not WorldMapFrame.ScrollContainer.Child then return end
  local child=WorldMapFrame.ScrollContainer.Child;frame:ClearAllPoints();frame:SetParent(child);frame:SetAllPoints(child);frame:SetFrameLevel(child:GetFrameLevel()+8);self:RefreshMapOverlay()
 end
 if WorldMapFrame then
  WorldMapFrame:HookScript("OnShow",attach)
  if WorldMapFrame.ScrollContainer then WorldMapFrame.ScrollContainer:HookScript("OnSizeChanged",function() if WorldMapFrame:IsShown() then attach() end end) end
 end
 local ev=CreateFrame("Frame");ev:RegisterEvent("WORLD_MAP_UPDATE");ev:SetScript("OnEvent",function() if WorldMapFrame and WorldMapFrame:IsShown() then attach() end end)
 frame:Hide()
end

function WP:ToggleMapRoutes()
 if not self.mapOverlayHost then self:InitializeMapOverlay() end
 if not WorldMapFrame then self:Print("World map is unavailable.");return end
 if not WorldMapFrame:IsShown() then if C_Map and C_Map.OpenWorldMap then C_Map.OpenWorldMap(visibleMapID()) elseif ToggleWorldMap then ToggleWorldMap() end end
 self.mapOverlayHost:Show();self:RefreshMapOverlay()
end
