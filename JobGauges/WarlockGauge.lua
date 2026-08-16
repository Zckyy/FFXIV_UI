--print("Warlock Soul Shard Gauge Loaded")

local _, class = UnitClass("player")
if class ~= "WARLOCK" then return end

local MAX_SOUL_SHARDS = 5
local POWER_TYPE = 7  
local gaugeFullSFX = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Gauge_Full.ogg" 
 local function PlayGaugeSFX(filePath)
    if FFXIV_UI_DB and FFXIV_UI_DB.sfxEnabled then
        FFXIV_UI_PlaySoundFile(filePath)
    end
end

local frame = CreateFrame("Frame", "SoulShardTrackerFrame", UIParent)
frame:SetSize(350, 350)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)

frame.base = frame:CreateTexture(nil, "BACKGROUND")
frame.base:SetAllPoints(frame)
frame.base:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Warlock\\FFLockFrame")

local anchor = FFXIV_UI_Anchors.JobGauge
frame:SetParent(anchor)
frame:ClearAllPoints()
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)

frame.orbs = {}

local orbTextures = {
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Warlock\\FFLock1",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Warlock\\FFLock2",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Warlock\\FFLock3",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Warlock\\FFLock4",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Warlock\\FFLock5",
}

for i = 1, MAX_SOUL_SHARDS do
    local orb = frame:CreateTexture(nil, "ARTWORK")
    orb:SetSize(350, 350)
    orb:SetPoint("CENTER", frame, "CENTER", 0, 0)
    orb:SetTexture(orbTextures[i])
    orb:Hide()
    frame.orbs[i] = orb
end
local previousShards = nil

local FADE_TIME = 0.15
local function UpdateSoulShards()
    local shards = UnitPower("player", POWER_TYPE) or 0

    if previousShards == nil then
        previousShards = shards
    end

    for i = 1, MAX_SOUL_SHARDS do
        if i <= shards then
            frame.orbs[i]:Show()
            UIFrameFadeIn(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 1)
        else
            frame.orbs[i]:Hide()
            UIFrameFadeOut(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 0)
        end
    end

    if shards == MAX_SOUL_SHARDS and previousShards < MAX_SOUL_SHARDS then
         PlayGaugeSFX(gaugeFullSFX)
    end

    previousShards = shards
end

frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateSoulShards()
    elseif unit == "player" and powerType == "SOUL_SHARDS" then
        UpdateSoulShards()
    end
end)
