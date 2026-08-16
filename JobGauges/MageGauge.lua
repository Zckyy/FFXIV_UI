 --print ("Mage Gauge Loaded")
local _, class = UnitClass("player")
if class ~= "MAGE" then return end

local ADDON_NAME = ...
local MAX_ARCANE_CHARGES = 4
local POWER_TYPE = Enum.PowerType.ArcaneCharges

local gaugeFullSFX = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Gauge_Full.ogg"    
local function PlayGaugeSFX(filePath)
    if FFXIV_UI_DB and FFXIV_UI_DB.sfxEnabled then
        FFXIV_UI_PlaySoundFile(filePath)
    end
end
 
local frame = CreateFrame("Frame", "ArcaneChargeFrame", UIParent)
frame:SetSize(300, 300)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
 
frame.base = frame:CreateTexture(nil, "BACKGROUND")
frame.base:SetAllPoints(frame)
frame.base:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\MAGE\\FFArcaneFrame")

local anchor = FFXIV_UI_Anchors.JobGauge

 
frame:SetParent(anchor)
frame:ClearAllPoints()
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
 
frame.orbs = {}

local orbTextures = {
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Mage\\FFArcaneCharge1.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Mage\\FFArcaneCharge2.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Mage\\FFArcaneCharge3.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Mage\\FFArcaneCharge4.tga",
 
}

for i = 1, MAX_ARCANE_CHARGES do
    local orb = frame:CreateTexture(nil, "ARTWORK")
    orb:SetSize(300, 300)
    orb:SetPoint("CENTER", frame, "CENTER", 0, 0)
    orb:SetTexture(orbTextures[i])
    orb:Hide()

    frame.orbs[i] = orb
end



local previousArcaneCharges = nil

local FADE_TIME = 0.15
 
local function UpdateArcaneCharges()
    local power = UnitPower("player", POWER_TYPE) or 0

    if previousArcaneCharges == nil then
        previousArcaneCharges = power
    end

    for i = 1, MAX_ARCANE_CHARGES do
        if i <= power then
            frame.orbs[i]:Show()
            UIFrameFadeIn(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 1)
        else
            frame.orbs[i]:Hide()
            UIFrameFadeOut(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 0)
        end
    end

    if power == MAX_ARCANE_CHARGES and previousArcaneCharges < MAX_ARCANE_CHARGES then
         PlayGaugeSFX(gaugeFullSFX)
    end

    previousArcaneCharges = power
end

 
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateArcaneCharges()
    elseif unit == "player" and powerType == "ARCANE_CHARGES" then
        UpdateArcaneCharges()
    end
end)
