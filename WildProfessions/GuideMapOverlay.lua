local _, WP = ...
local function clear(self) for _,v in ipairs(self.routeMarks or {}) do v:Hide() end end
local function makeMark(parent,texture,size,r,g,b)
 local t=parent:CreateTexture(nil,"OVERLAY");t:SetTexture(texture);t:SetSize(size,size);t:SetVertexColor(r,g,b,0.95);return t
end
local function visibleMapID()
 if WorldMapFrame and type(WorldMapFrame.GetMapID)=="function" then local ok,id=pcall(WorldMapFrame.GetMapID,WorldMapFrame);if ok then return id end end
end
function WP:RefreshMapOverlay()
 local host=self.mapOverlayHost;if not host or self.mapRoutesVisible==false then return end;clear(host)
 local id=visibleMapID();if not id then return end
 local route=self:GetGuideRoute(self.selectedProfession);if not route then return end
 local points={}
 for _,step in ipairs(route.steps or {}) do
  if step.mapID==id and type(step.x)=="number" and type(step.y)=="number" then points[#points+1]={x=step.x/100,y=step.y/100,label=step.title or step.zone} end
  for _,alt in pairs(step.mapRoutes or {}) do if alt.mapID==id then for _,pt in ipairs(alt.points or {}) do points[#points+1]={x=pt[1]/100,y=pt[2]/100,label=step.title or step.zone} end end end
 end
 if #points==0 then return end
 for i=1,#points-1 do local q,r=points[i],points[i+1];local dx=(r.x-q.x)*host:GetWidth();local dy=(r.y-q.y)*host:GetHeight();local line=host:CreateTexture(nil,"ARTWORK");line:SetTexture("Interface/Buttons/WHITE8X8");line:SetVertexColor(0.1,1,0.35,0.85);line:SetSize(math.sqrt(dx*dx+dy*dy),4);line:SetPoint("CENTER",host,"TOPLEFT",((q.x+r.x)/2)*host:GetWidth(),-((q.y+r.y)/2)*host:GetHeight());line:SetRotation(math.atan2 and math.atan2(-dy,dx) or 0);line:Show();host.routeMarks[#host.routeMarks+1]=line end
 for i,pt in ipairs(points) do local pin=makeMark(host,"Interface/Buttons/WHITE8X8",16,1,0.85,0.1);pin:SetPoint("CENTER",host,"TOPLEFT",pt.x*host:GetWidth(),-pt.y*host:GetHeight());pin:Show();host.routeMarks[#host.routeMarks+1]=pin;local label=host:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");label:SetText(i);label:SetPoint("CENTER",pin,"CENTER");label:SetTextColor(0,0,0,1);label:Show();host.routeMarks[#host.routeMarks+1]=label end
end
function WP:InitializeMapOverlay()
 if self.mapOverlayHost then return end
 local frame=CreateFrame("Frame","WildProfessionsMapOverlay",UIParent);frame.routeMarks={};self.mapOverlayHost=frame
 local function attach()
  if not WorldMapFrame then return end
  local child=(WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child) or (WorldMapFrame.ScrollContainer or WorldMapFrame);frame:SetFrameStrata("HIGH");frame:ClearAllPoints();frame:SetParent(child);frame:SetAllPoints(child);frame:SetFrameLevel((child:GetFrameLevel() or 1)+50);self:RefreshMapOverlay()
 end
 self.attachMapOverlay=attach
 if WorldMapFrame then
  WorldMapFrame:HookScript("OnShow",attach)
  if WorldMapFrame.ScrollContainer then WorldMapFrame.ScrollContainer:HookScript("OnSizeChanged",function() if WorldMapFrame:IsShown() then attach() end end) end
 end
 local ev=CreateFrame("Frame");local elapsed,lastMap=0,nil
 ev:SetScript("OnUpdate",function(_,dt) elapsed=elapsed+dt;if elapsed<0.35 then return end;elapsed=0
  if WorldMapFrame and WorldMapFrame:IsShown() then local id=visibleMapID();if id and id~=lastMap then lastMap=id;attach() end end
 end)
 frame:Hide()
end

function WP:ToggleMapRoutes()
 if not self.mapOverlayHost then self:InitializeMapOverlay() end
 if self.mapRoutesVisible then self.mapRoutesVisible=false;self.mapOverlayHost:Hide();self:Print("Map route overlay hidden.");return end
 local state=self:GetCurrentGuideState()
 local mapID=state and state.mapID
 if not mapID then self:Print("Select a gathering guide step with map coordinates first.");return end
 self.mapRoutesVisible=true
 if C_Map and C_Map.OpenWorldMap then C_Map.OpenWorldMap(mapID) elseif ToggleWorldMap then ToggleWorldMap() end
 self.mapOverlayHost:Show()
 if self.attachMapOverlay then self.attachMapOverlay() end
 if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
  local info=C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  if info==mapID then self:RefreshMapOverlay() end
 end
end
