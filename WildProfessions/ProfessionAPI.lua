local _, WP = ...

local function safeNumber(value)
    if type(value) ~= "number" then return nil end
    local ok, result = pcall(function()
        if value ~= value or value < 0 or value > 1000000000 then return nil end
        return value
    end)
    if ok then return result end
    return nil
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return false end
    return pcall(fn, ...)
end

local function getProfessionInfo(index)
    if type(GetProfessionInfo) ~= "function" then return nil end
    local ok, name, icon, skill, maxSkill, _, _, skillLineID = safeCall(GetProfessionInfo, index)
    if not ok then return nil end
    if type(name) ~= "string" then return nil end
    return {
        name = name,
        icon = icon,
        skill = safeNumber(skill) or 0,
        maxSkill = safeNumber(maxSkill) or 0,
        skillLineID = safeNumber(skillLineID),
    }
end

function WP:ScanProfessions()
    local found = {}

    -- Forever's native profession pane uses C_TradeSkillUI. Enumerate only
    -- skill lines the client reports; never infer a skill or recipe from names.
    local ts = C_TradeSkillUI
    if ts and type(ts.GetAllProfessionTradeSkillLines) == "function"
        and type(ts.GetProfessionInfoBySkillLineID) == "function" then
        local ok, lines = safeCall(ts.GetAllProfessionTradeSkillLines)
        if ok and type(lines) == "table" then
            for _, lineID in ipairs(lines) do
                local infoOK, info = safeCall(ts.GetProfessionInfoBySkillLineID, lineID)
                if infoOK and type(info) == "table" and type(info.professionName) == "string" then
                    found[info.professionName] = {
                        name = info.professionName,
                        skill = safeNumber(info.skillLevel) or 0,
                        maxSkill = safeNumber(info.maxSkillLevel) or 0,
                        skillLineID = safeNumber(lineID),
                        professionID = safeNumber(info.professionID),
                        isPrimary = info.isPrimaryProfession == true,
                    }
                end
            end
        end
    end

    -- Camelot exposes GetProfessions() for the native right-side profession
    -- tabs. Use it as a compatibility fallback when the C API returns nothing.
    if next(found) == nil and type(GetProfessions) == "function" then
        local ok, p1, p2, p3, p4, p5, p6, p7 = safeCall(GetProfessions)
        if ok then
            local indices = { p1, p2, p3, p4, p5, p6, p7 }
            for i = 1, 7 do
                local index = indices[i]
                if type(index) == "number" then
                    local info = getProfessionInfo(index)
                    if info then found[info.name] = info end
                end
            end
        end
    end

    local now = time and time() or 0
    for name, info in pairs(found) do
        info.updatedAt = now
        local previous = self.character.professions[name]
        if previous and (previous.skill or 0) ~= info.skill then
            table.insert(self.character.history, {
                profession = name,
                from = previous.skill or 0,
                to = info.skill,
                at = now,
            })
            while #self.character.history > 200 do table.remove(self.character.history, 1) end
        end
        self.character.professions[name] = info
    end
    self.professions = found
    if not self.selectedProfession or not found[self.selectedProfession] then
        for name in pairs(found) do self.selectedProfession = name; break end
    end
    return found
end

function WP:ScanOpenProfession()
    -- Intentionally limited to an event-triggered snapshot. Recipe enumeration is
    -- deferred until the Forever API surface is confirmed for the target build.
    local ts = C_TradeSkillUI
    if ts and type(ts.GetBaseProfessionInfo) == "function" then
        local ok, info = safeCall(ts.GetBaseProfessionInfo)
        if ok and type(info) == "table" and type(info.professionName) == "string" then
            local name = info.professionName
            self.openProfessionName = name
            self.selectedProfession = name
            self.professions[name] = {
                name = name,
                skill = safeNumber(info.skillLevel) or 0,
                maxSkill = safeNumber(info.maxSkillLevel) or 0,
                professionID = safeNumber(info.professionID),
                isPrimary = info.isPrimaryProfession == true,
            }
        end
    elseif type(GetTradeSkillLine) == "function" then
        local ok, name = safeCall(GetTradeSkillLine)
        if ok and type(name) == "string" and name ~= "" then self.openProfessionName = name end
    end
end

function WP:GetProfessionList()
    local result = {}
    for name, info in pairs(self.professions) do result[#result + 1] = info end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

