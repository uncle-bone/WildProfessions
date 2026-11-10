local _, WF = ...
local function backdrop(frame, bg, border)
    if frame.SetBackdrop then
        frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
        frame:SetBackdropColor(bg[1],bg[2],bg[3],bg[4] or 1); frame:SetBackdropBorderColor(border[1],border[2],border[3],1)
    end
end
local function label(parent,text,size,color,template)
    local fs=parent:CreateFontString(nil,"OVERLAY",template or "GameFontHighlight")
    if size and fs.SetFont then fs:SetFont("Fonts\\FRIZQT__.TTF",size,"") end
    fs:SetTextColor(color[1],color[2],color[3]); fs:SetText(text or "")
    return fs
end
local function button(parent,text,w,h,fn)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate"); b:SetSize(w,h); b:SetText(text); b:SetScript("OnClick",fn); return b
end
local function lower(s) return tostring(s or ""):lower() end
local function key(s) return lower(s):gsub("[^%a]","") end
local function faction() return UnitFactionGroup and UnitFactionGroup("player") end
local function professionSkills()
    local out={}
    if GetProfessions and GetProfessionInfo then
        for _,slot in ipairs({GetProfessions()}) do
            if slot then local name,_,rank,maxRank=GetProfessionInfo(slot); if name then out[name]={rank=rank or 0,max=maxRank or 0} end end
        end
    end
    return out
end
local function normalize(category,row,source)
    if type(row)~="table" then return end
    local points=type(row.points)=="table" and row.points or {}
    return {category=category or row.category or "Other",item=row.item or row.name or row.title or row.bracket or "Gathering route",
        zone=row.zone or "Unknown zone",mapID=tonumber(row.mapID),points=points,skill=tonumber(row.skill or row.target or row.skillRequirement) or 0,
        level=tonumber(row.levelRequirement) or 0,faction=row.faction,source=row.source or source or "Bundled route",
        unmapped=row.unmapped==true or not tonumber(row.mapID) or #points==0}
end
function WF:BuildRoutes()
    local routes,seen={},{}
    local function add(cat,row,src)
        local e=normalize(cat,row,src); if not e then return end
        local sig=table.concat({key(e.category),key(e.zone),tostring(e.mapID or ""),key(e.item),tostring(e.faction or "")},"|")
        local old=seen[sig]
        if old then if #e.points>#old.points then old.points=e.points;old.mapID=e.mapID;old.unmapped=e.unmapped end
            if old.skill==0 and e.skill>0 then old.skill=e.skill end
            return
        end
        seen[sig]=e;routes[#routes+1]=e
    end
    for cat,rows in pairs(WF.ZygorGatheringIndex or {}) do
        local name=({herbalism="Herbalism",mining="Mining",skinning="Skinning",fishing="Fishing"})[cat] or cat
        for _,row in ipairs(rows) do add(name,row,"Imported gathering route") end
    end
    for _,row in ipairs(WF.ZygorFarmingGuideIndex or {}) do add(row.category,row,"Imported farming route") end
    for _,route in pairs(WF.RouteData or {}) do
        local cat=route.name or "Gathering"
        for _,row in ipairs(route.farmRoutes or {}) do add(cat,row,"Guide route") end
        for _,step in ipairs(route.steps or {}) do
            for zone,mapRoute in pairs(step.mapRoutes or {}) do
                add(cat,{name=step.title,zone=zone,mapID=mapRoute.mapID,points=mapRoute.points,skill=step.min or step.target,faction=mapRoute.faction},"Profession guide route")
            end
            for _,zone in ipairs(step.choices or {}) do add(cat,{name=step.title,zone=zone,skill=step.min or step.target,source="Guide zone suggestion",unmapped=true},"Guide zone suggestion") end
        end
    end
    table.sort(routes,function(a,b) if a.category~=b.category then return a.category<b.category end if a.zone~=b.zone then return a.zone<b.zone end if a.skill~=b.skill then return a.skill<b.skill end return a.item<b.item end)
    self.routes=routes
end
function WF:CanUse(route)
    if not self.db.matchCharacter then return true end
    local f=faction()
    if route.faction and f and route.faction~=f then return false end
    if route.level>0 and UnitLevel and route.level>UnitLevel("player") then return false end
    if route.skill>0 then local skills=professionSkills();local prof=skills[route.category]
        if prof and prof.rank>0 and route.skill>prof.rank then return false end
    end
    return true
end
local function currentMap()
    if WorldMapFrame and WorldMapFrame.GetMapID then local ok,id=pcall(WorldMapFrame.GetMapID,WorldMapFrame);if ok then return id end end
    if C_Map and C_Map.GetBestMapForUnit then local ok,id=pcall(C_Map.GetBestMapForUnit,"player");if ok then return id end end
end
local function openMap(id)
    if not id then return end
    if C_Map and C_Map.OpenWorldMap then pcall(C_Map.OpenWorldMap,id)
    elseif ToggleWorldMap then ToggleWorldMap();if SetMapByID then pcall(SetMapByID,id) end end
end
function WF:SelectRoute(route)
    self.db.route=route; self.db.waypoint=1
    self:UpdateDetails(); self:RefreshOverlay(); self:UpdateArrow()
end
function WF:TrackRoute(route)
    self:SelectRoute(route)
    if route.mapID then openMap(route.mapID) end
    self.arrow:Show()
    self:Print("Tracking "..route.item.." in "..route.zone..".")
end
function WF:StopRoute()
    self.db.route=nil; self.arrow:Hide(); self:ClearOverlay(); self:UpdateDetails()
    self:Print("Route tracking stopped.")
end
function WF:NextWaypoint()
    local r=self.db.route
    if not r or #r.points==0 then return self:Print("Select a mapped route first.") end
    self.db.waypoint=(self.db.waypoint or 1)%#r.points+1
    self:UpdateArrow();self:RefreshOverlay()
end
function WF:ClearOverlay()
    for _,v in ipairs(self.overlayMarks or {}) do v:Hide() end; self.overlayMarks={}
end
function WF:RefreshOverlay()
    self:ClearOverlay()
    local route=self.db and self.db.route
    local host=self.mapHost
    if not route or route.mapID~=currentMap() or not host then return end
    local w,h=host:GetWidth(),host:GetHeight(); if w<10 or h<10 then return end
    local pts=route.points
    for i=1,#pts-1 do
        local a,b=pts[i],pts[i+1];local x1,y1=(a[1] or 0)/100,(a[2] or 0)/100;local x2,y2=(b[1] or 0)/100,(b[2] or 0)/100
        local dx,dy=(x2-x1)*w,(y2-y1)*h;local len=math.sqrt(dx*dx+dy*dy)
        if len>1 then local line=host:CreateTexture(nil,"ARTWORK");line:SetTexture("Interface\\Buttons\\WHITE8X8");line:SetVertexColor(0.34,0.88,0.38,0.8);line:SetSize(len,3);line:SetPoint("CENTER",host,"TOPLEFT",(x1+x2)*w/2,-(y1+y2)*h/2);line:SetRotation(math.atan2 and math.atan2(-dy,dx) or 0);self.overlayMarks[#self.overlayMarks+1]=line end
    end
    for i,p in ipairs(pts) do
        local pin=CreateFrame("Frame",nil,host);pin:SetSize(18,18);pin:SetPoint("CENTER",host,"TOPLEFT",(p[1] or 0)*w/100,-(p[2] or 0)*h/100)
        local t=pin:CreateTexture(nil,"OVERLAY");t:SetTexture("Interface\\Buttons\\WHITE8X8");t:SetVertexColor(i==(self.db.waypoint or 1) and 1 or 0.9,i==(self.db.waypoint or 1) and 0.72 or 0.52,0.18,1);t:SetAllPoints()
        local fs=label(pin,tostring(i),9,{0.08,0.08,0.06},"GameFontNormalSmall");fs:SetPoint("CENTER")
        pin:EnableMouse(true);pin:SetScript("OnMouseDown",function() self.db.waypoint=i;self:UpdateArrow();self:RefreshOverlay() end)
        pin:SetScript("OnEnter",function(f) GameTooltip:SetOwner(f,"ANCHOR_RIGHT");GameTooltip:SetText(route.item.." - "..route.zone);GameTooltip:AddLine("Waypoint "..i,1,0.8,0.25);GameTooltip:Show() end)
        pin:SetScript("OnLeave",function() GameTooltip:Hide() end)
        self.overlayMarks[#self.overlayMarks+1]=pin
    end
end
function WF:AttachMap()
    if not WorldMapFrame then return end
    local child=(WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child) or WorldMapFrame.ScrollContainer or WorldMapFrame
    self.mapHost=child
    self:RefreshOverlay()
end
function WF:UpdateArrow()
    local r=self.db and self.db.route
    if not r or not r.mapID or #r.points==0 then self.arrow:Hide();return end
    local i=math.max(1,math.min(#r.points,self.db.waypoint or 1));local p=r.points[i]
    self.arrowText:SetText(r.item.."  •  "..r.zone.."\nWaypoint "..i.."/"..#r.points.."  •  "..math.floor((p[1] or 0)+0.5)..", "..math.floor((p[2] or 0)+0.5))
    if not self.arrow:IsShown() then self.arrow:Show() end
    if currentMap()==r.mapID and C_Map and C_Map.GetPlayerMapPosition then
        local ok,pos=pcall(C_Map.GetPlayerMapPosition,r.mapID,"player")
        if ok and pos and pos.GetXY then
            local x,y=pos:GetXY();local dx=(p[1] or 0)/100-x;local dy=y-(p[2] or 0)/100
            if math.sqrt(dx*dx+dy*dy)<0.008 then self:NextWaypoint() end
        end
    end
end
function WF:UpdateDetails()
    local r=self.db and self.db.route
    self.detailTitle:SetText(r and r.item or "Choose a route")
    self.detailMeta:SetText(r and (r.category.."  •  "..r.zone.."  •  "..(r.faction or "Any faction").."  •  "..(r.skill>0 and ("Skill "..r.skill.."+") or "Any skill")) or "Select a route to preview its waypoint path.")
    self.detailSource:SetText(r and (r.source..(r.unmapped and "  •  No waypoint map" or "")) or "Routes are suggestions; imported waypoints are not verified live resource spawns.")
    self.trackButton:SetEnabled(r and not r.unmapped)
    self.stopButton:SetEnabled(r~=nil)
    local points=r and r.points or {}
    self.waypointText:SetText(r and (#points>0 and (tostring(#points).." mapped waypoints. The route advances as you reach each point.") or "This entry has a zone recommendation but no mapped waypoints.") or "Farming routes by profession, zone, skill range, and faction.")
end
function WF:RefreshList()
    if not self.list then return end
    local q=lower(self.search:GetText()); local cat=self.db.selectedCategory or "All"
    for _,row in ipairs(self.rows) do row:Hide() end
    local shown,index=0,0
    for _,r in ipairs(self.routes or {}) do
        local text=lower(r.category.." "..r.item.." "..r.zone.." "..r.source)
        if (cat=="All" or r.category==cat) and (q=="" or text:find(q,1,true)) and self:CanUse(r) then
            shown=shown+1;local row=self.rows[shown]
            if not row then
                row=CreateFrame("Button",nil,self.list,"BackdropTemplate");row:SetHeight(48)
                backdrop(row,{0.075,0.065,0.045,1},{0.52,0.40,0.20})
                row.title=label(row,"",12,{0.96,0.86,0.59},"GameFontNormal");row.title:SetPoint("TOPLEFT",10,-7);row.title:SetPoint("RIGHT",-8,0);row.title:SetJustifyH("LEFT")
                row.sub=label(row,"",10,{0.76,0.75,0.69});row.sub:SetPoint("BOTTOMLEFT",10,6);row.sub:SetPoint("RIGHT",-8,0);row.sub:SetJustifyH("LEFT")
                row:SetScript("OnClick",function(b) WF:SelectRoute(b.route) end)
                row:SetScript("OnEnter",function(b) if b.route then b:SetBackdropColor(0.16,0.13,0.07,1) end end)
                row:SetScript("OnLeave",function(b) b:SetBackdropColor(0.075,0.065,0.045,1) end)
                self.rows[shown]=row
            end
            row.route=r;row.title:SetText(r.item);row.sub:SetText(r.zone.."  •  "..(r.category or "Other").."  •  "..(#r.points>0 and (#r.points.." pts") or "zone only"))
            row:ClearAllPoints();row:SetPoint("TOPLEFT",self.list,"TOPLEFT",0,-(shown-1)*54);row:SetPoint("RIGHT",self.list,"RIGHT",0,0);row:Show()
        end
    end
    self.list:SetHeight(math.max(self.scroll:GetHeight(),shown*54))
    self.resultCount:SetText(shown.." routes")
end
function WF:Initialize()
    if self.frame then return end
    self:BuildRoutes()
    local f=CreateFrame("Frame","WildFarmingWindow",UIParent,"BackdropTemplate");f:SetSize(900,600);f:SetPoint("CENTER");f:SetFrameStrata("DIALOG");f:SetMovable(true);f:EnableMouse(true);f:SetClampedToScreen(true);backdrop(f,{0.055,0.047,0.032,0.99},{0.62,0.47,0.23})
    f:SetScript("OnMouseDown",function(x,b) if b=="LeftButton" and x:IsMovable() then x:StartMoving() end end);f:SetScript("OnMouseUp",function(x) x:StopMovingOrSizing() end)
    local title=label(f,"WILDFARMING",18,{1,0.78,0.31},"GameFontNormalLarge");title:SetPoint("TOPLEFT",24,-20)
    local sub=label(f,"ROUTE PLANNER  /  GATHER  /  TRACK",10,{0.72,0.66,0.50});sub:SetPoint("TOPLEFT",26,-47)
    local close=CreateFrame("Button",nil,f,"UIPanelCloseButton");close:SetPoint("TOPRIGHT",-4,-4)
    local filter=button(f,"All Professions",150,25,function(b)
        local cats={"All"};local seen={};for _,r in ipairs(WF.routes) do if not seen[r.category] then seen[r.category]=true;cats[#cats+1]=r.category end end;table.sort(cats);table.remove(cats,1);table.insert(cats,1,"All")
        local i=1;for n,v in ipairs(cats) do if v==WF.db.selectedCategory then i=n end end;WF.db.selectedCategory=cats[i%#cats+1];b:SetText(WF.db.selectedCategory=="All" and "All Professions" or WF.db.selectedCategory);WF:RefreshList()
    end);filter:SetPoint("TOPLEFT",22,-72);self.categoryButton=filter
    local search=CreateFrame("EditBox",nil,f,"InputBoxTemplate");search:SetSize(220,24);search:SetAutoFocus(false);search:SetTextInsets(6,6,0,0);search:SetPoint("LEFT",filter,"RIGHT",12,0);search:SetText(self.db.search or "");search:SetScript("OnTextChanged",function(e) WF.db.search=e:GetText();WF:RefreshList() end);self.search=search
    local match=button(f,self.db.matchCharacter and "Faction/skill: ON" or "Faction/skill: OFF",132,25,function(b) WF.db.matchCharacter=not WF.db.matchCharacter;b:SetText(WF.db.matchCharacter and "Faction/skill: ON" or "Faction/skill: OFF");WF:RefreshList() end);match:SetPoint("LEFT",search,"RIGHT",10,0)
    local count=label(f,"",10,{0.81,0.75,0.61});count:SetPoint("RIGHT",-28,-84);self.resultCount=count
    local left=CreateFrame("Frame",nil,f,"BackdropTemplate");left:SetPoint("TOPLEFT",20,-108);left:SetPoint("BOTTOMLEFT",20,20);left:SetWidth(390);backdrop(left,{0.025,0.024,0.02,1},{0.38,0.31,0.19})
    local scroll=CreateFrame("ScrollFrame",nil,left,"UIPanelScrollFrameTemplate");scroll:SetPoint("TOPLEFT",10,-10);scroll:SetPoint("BOTTOMRIGHT",-28,10)
    local list=CreateFrame("Frame",nil,scroll);list:SetSize(340,400);scroll:SetScrollChild(list);self.scroll,self.list,self.rows=scroll,list,{}
    local right=CreateFrame("Frame",nil,f,"BackdropTemplate");right:SetPoint("TOPLEFT",left,"TOPRIGHT",14,0);right:SetPoint("BOTTOMRIGHT",-20,20);backdrop(right,{0.09,0.075,0.046,1},{0.62,0.47,0.23})
    local icon=right:CreateTexture(nil,"ARTWORK");icon:SetTexture("Interface\\Icons\\INV_Misc_Herb_01");icon:SetSize(52,52);icon:SetPoint("TOPLEFT",20,-20);self.detailIcon=icon
    local dt=label(right,"Choose a route",18,{1,0.82,0.42},"GameFontNormalLarge");dt:SetPoint("TOPLEFT",icon,"TOPRIGHT",14,-2);dt:SetPoint("RIGHT",-16,0);dt:SetJustifyH("LEFT");self.detailTitle=dt
    local dm=label(right,"",12,{0.86,0.82,0.72});dm:SetPoint("TOPLEFT",icon,"BOTTOMLEFT",0,-14);dm:SetPoint("RIGHT",-16,0);dm:SetJustifyH("LEFT");dm:SetHeight(42);dm:SetJustifyV("TOP");dm:SetWordWrap(true);self.detailMeta=dm
    local line=right:CreateTexture(nil,"ARTWORK");line:SetTexture("Interface\\Buttons\\WHITE8X8");line:SetVertexColor(0.60,0.44,0.20,0.9);line:SetHeight(1);line:SetPoint("TOPLEFT",20,-142);line:SetPoint("RIGHT",-20,0)
    local wpTitle=label(right,"ROUTE WAYPOINTS",11,{0.83,0.70,0.46});wpTitle:SetPoint("TOPLEFT",20,-162)
    local wptext=label(right,"",12,{0.90,0.88,0.82});wptext:SetPoint("TOPLEFT",20,-185);wptext:SetPoint("RIGHT",-18,0);wptext:SetHeight(78);wptext:SetJustifyH("LEFT");wptext:SetJustifyV("TOP");wptext:SetWordWrap(true);self.waypointText=wptext
    local source=label(right,"",10,{0.71,0.68,0.59});source:SetPoint("TOPLEFT",20,-275);source:SetPoint("RIGHT",-18,0);source:SetHeight(42);source:SetJustifyH("LEFT");source:SetJustifyV("TOP");source:SetWordWrap(true);self.detailSource=source
    local track=button(right,"TRACK THIS ROUTE",180,34,function() if self.db.route then self:TrackRoute(self.db.route) end end);track:SetPoint("BOTTOMLEFT",20,54);self.trackButton=track
    local stop=button(right,"STOP",92,34,function() self:StopRoute() end);stop:SetPoint("LEFT",track,"RIGHT",10,0);self.stopButton=stop
    local nextb=button(right,"NEXT POINT",120,34,function() self:NextWaypoint() end);nextb:SetPoint("LEFT",stop,"RIGHT",8,0)
    self.frame=f
    self.arrow=CreateFrame("Frame","WildFarmingArrow",UIParent,"BackdropTemplate");self.arrow:SetSize(310,72);self.arrow:SetPoint("CENTER",UIParent,"CENTER",0,-180);self.arrow:SetFrameStrata("HIGH");self.arrow:SetMovable(true);self.arrow:EnableMouse(true);backdrop(self.arrow,{0.035,0.03,0.02,0.96},{0.78,0.54,0.22})
    self.arrow:SetScript("OnMouseDown",function(x,b) if b=="LeftButton" then x:StartMoving() end end);self.arrow:SetScript("OnMouseUp",function(x) x:StopMovingOrSizing() end)
    local at=label(self.arrow,"",12,{1,0.88,0.55},"GameFontNormal");at:SetPoint("CENTER");at:SetPoint("LEFT",12,0);at:SetPoint("RIGHT",-12,0);at:SetJustifyH("CENTER");self.arrowText=at;self.arrow:Hide()
    self.overlayMarks={}
    if WorldMapFrame then WorldMapFrame:HookScript("OnShow",function() self:AttachMap() end);if WorldMapFrame.ScrollContainer then WorldMapFrame.ScrollContainer:HookScript("OnSizeChanged",function() if WorldMapFrame:IsShown() then self:AttachMap() end end) end end
    local tick=CreateFrame("Frame");local elapsed=0;tick:SetScript("OnUpdate",function(_,dt) elapsed=elapsed+dt;if elapsed<0.35 then return end;elapsed=0;if WorldMapFrame and WorldMapFrame:IsShown() then self:AttachMap() end;if self.db.route then self:UpdateArrow() end end)
    self:RefreshList();self:UpdateDetails();self.frame:Hide()
    if self.db.route then self.arrow:Show();self:UpdateArrow() end
end
function WF:Toggle()
    if not self.frame then self:Initialize() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show();self:RefreshList() end
end
