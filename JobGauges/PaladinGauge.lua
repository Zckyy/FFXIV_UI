 --print ("Paladin Gauge Loaded")
local _, class = UnitClass("player")
if class ~= "PALADIN" then return end

local ADDON_NAME = ...
local MAX_HOLY_POWER = 5
local POWER_TYPE = Enum.PowerType.HolyPower

local gaugeFullSFX = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Gauge_Full.ogg"  
local function PlayGaugeSFX(filePath)
    if FFXIV_UI_DB and FFXIV_UI_DB.sfxEnabled then
        FFXIV_UI_PlaySoundFile(filePath)
    end
end
 
local frame = CreateFrame("Frame", "HolyPowerTrackerFrame", UIParent)
frame:SetSize(350, 350)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
 
frame.base = frame:CreateTexture(nil, "BACKGROUND")
frame.base:SetAllPoints(frame)
frame.base:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Paladin\\FFPaladinFrame")

local anchor = FFXIV_UI_Anchors.JobGauge

 
frame:SetParent(anchor)
frame:ClearAllPoints()
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
 
frame.orbs = {}

local orbTextures = {
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Paladin\\HolyPower1.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Paladin\\HolyPower2.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Paladin\\HolyPower3.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Paladin\\HolyPower4.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Paladin\\HolyPower5.tga",
}

for i = 1, MAX_HOLY_POWER do
    local orb = frame:CreateTexture(nil, "ARTWORK")
    orb:SetSize(350, 350)
    orb:SetPoint("CENTER", frame, "CENTER", 0, 0)
    orb:SetTexture(orbTextures[i])
    orb:Hide()

    frame.orbs[i] = orb
end

local previousHolyPower = nil

local FADE_TIME = 0.15 

local function UpdateHolyPower()
    local power = UnitPower("player", POWER_TYPE) or 0

    if previousHolyPower == nil then
        previousHolyPower = power
    end

    for i = 1, MAX_HOLY_POWER do
        if i <= power then
            frame.orbs[i]:Show()
            UIFrameFadeIn(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 1)
        else
            frame.orbs[i]:Hide()
            UIFrameFadeOut(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 0)
        end
    end

    if power == MAX_HOLY_POWER and previousHolyPower < MAX_HOLY_POWER then
          PlayGaugeSFX(gaugeFullSFX)
    end

    previousHolyPower = power
end

 
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateHolyPower()
    elseif unit == "player" and powerType == "HOLY_POWER" then
        UpdateHolyPower()
    end
end)
