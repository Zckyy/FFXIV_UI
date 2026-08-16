--print("DK Rune Gauge Loaded")

local _, class = UnitClass("player")
if class ~= "DEATHKNIGHT" then return end

local MAX_RUNES = 6
local RUNE_SIZE = 90
local gaugeFullSFX = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Gauge_Full.ogg"   

local frame = CreateFrame("Frame", "DKRuneFrame", UIParent)
frame:SetSize(300, 300)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)

frame.base = frame:CreateTexture(nil, "BACKGROUND")
frame.base:SetAllPoints(frame)
frame.base:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\DeathKnight\\FFDeathKnightBG")

local anchor = FFXIV_UI_Anchors.JobGauge
frame:SetParent(anchor)
frame:ClearAllPoints()
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)

frame.runes = {}

local function PlayGaugeSFX(filePath)
    if not FFXIV_UI_DB or not FFXIV_UI_DB.sfxEnabled then return end
    FFXIV_UI_PlaySoundFile(filePath)
end

local RUNE_POSITIONS = {
    [1] = { x = -50, y = -10 },
    [2] = { x =   0, y = -10 },
    [3] = { x =  50, y = -10 },
    [4] = { x = -25, y = -60 },
    [5] = { x =   25, y = -60 },
    [6] = { x =  75, y = -60 },
}


local RUNE_TEXTURE       = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\DeathKnight\\FFRuneFill.tga"
local RUNE_FRAME_TEXTURE = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\DeathKnight\\FFRuneFrame.tga"


local TEX_TOP, TEX_BOTTOM = 1, 0


local SPEC_COLORS = {

    [1] = {
        READY = { 1.0, 0.0, 0.25, 1.0 },
        DARK  = { 1.0, 0.5, 0.5, 0.5 },
    },


    [2] = {
        READY = { 0.25, 0.85, 1.0, 1.0 },
        DARK  = { 0.6, 0.85, 1.0, 0.5 },
    },


    [3] = {
        READY = { 0.7, 1.0, 0.2, 1.0 },
        DARK  = { 0.9, 1.0, 0.4, 0.5 },
    },
}

local FILL_COLOR_READY
local FILL_COLOR_DARK

local function UpdateSpecColors()
    local spec = GetSpecialization()
    local colors = SPEC_COLORS[spec] or SPEC_COLORS[1]

    FILL_COLOR_READY = colors.READY
    FILL_COLOR_DARK  = colors.DARK
end


for i = 1, MAX_RUNES do
    local pos = RUNE_POSITIONS[i]

    local rune = CreateFrame("Frame", nil, frame)
    rune:SetSize(RUNE_SIZE, RUNE_SIZE)
    rune:SetPoint("CENTER", frame, "CENTER", pos.x, pos.y)


    rune.frameTex = rune:CreateTexture(nil, "BACKGROUND")
    rune.frameTex:SetAllPoints(rune)
    rune.frameTex:SetTexture(RUNE_FRAME_TEXTURE)
    rune.frameTex:SetVertexColor(1, 1, 1, 1)


    rune.fill = rune:CreateTexture(nil, "ARTWORK")
    rune.fill:SetPoint("BOTTOM", rune, "BOTTOM")
    rune.fill:SetSize(RUNE_SIZE, RUNE_SIZE)
    rune.fill:SetTexture(RUNE_TEXTURE)

    rune.fill:SetHeight(0)
    rune.fill:SetTexCoord(0, 1, TEX_TOP, TEX_TOP)

    frame.runes[i] = rune
end


local function UpdateRune(runeIndex)
    local rune = frame.runes[runeIndex]
    if not rune then return end

    local start, duration, ready = GetRuneCooldown(runeIndex)

    if ready then
        rune.fill:SetHeight(RUNE_SIZE)
        rune.fill:SetTexCoord(0, 1, TEX_BOTTOM, TEX_TOP)
        rune.fill:SetVertexColor(unpack(FILL_COLOR_READY))
        rune.frameTex:SetVertexColor(unpack(FILL_COLOR_READY))
        rune:SetScript("OnUpdate", nil)
    else
        rune.fill:SetVertexColor(unpack(FILL_COLOR_DARK))
        rune.frameTex:SetVertexColor(1, 1, 1, 1)

        rune:SetScript("OnUpdate", function(self)
            local now = GetTime()
            local progress = (now - start) / duration
            progress = math.min(progress, 1)

            local height = RUNE_SIZE * progress
            self.fill:SetHeight(height)

            local croppedTop = TEX_TOP - (TEX_TOP - TEX_BOTTOM) * progress
            self.fill:SetTexCoord(0, 1, croppedTop, TEX_TOP)

            if progress >= 1 then
                self.fill:SetVertexColor(unpack(FILL_COLOR_READY))
                self.frameTex:SetVertexColor(unpack(FILL_COLOR_READY))
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
end

local previousReadyRunes = nil

local function CountReadyRunes()
    local count = 0
    for i = 1, MAX_RUNES do
        local _, _, ready = GetRuneCooldown(i)
        if ready then
            count = count + 1
        end
    end
    return count
end

local function UpdateAllRunes()
    local readyCount = CountReadyRunes()

    if previousReadyRunes == nil then
        previousReadyRunes = readyCount
    end

    for i = 1, MAX_RUNES do
        UpdateRune(i)
    end

    if readyCount == MAX_RUNES and previousReadyRunes < MAX_RUNES then
          PlayGaugeSFX(gaugeFullSFX)
    end

    previousReadyRunes = readyCount
end


frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("RUNE_POWER_UPDATE")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateSpecColors()
        UpdateAllRunes()

    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        UpdateSpecColors()
        UpdateAllRunes()

    elseif event == "RUNE_POWER_UPDATE" then
        UpdateAllRunes()
    end
end)
