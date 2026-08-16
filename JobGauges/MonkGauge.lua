--print("Monk Gauge Loaded")

local function PlayGaugeSFX(filePath)
    if not FFXIV_UI_DB or not FFXIV_UI_DB.sfxEnabled then return end
    FFXIV_UI_PlaySoundFile(filePath)
end

local _, class = UnitClass("player")
if class ~= "MONK" then return end

local ADDON_NAME = ...
local POWER_TYPE = Enum.PowerType.Chi

 
local SPEC_MONK_WINDWALKER = 3
local ASCENSION_SPELL_ID = 115396  
 
local FRAME_TEXTURE_NORMAL =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkFrame.tga"

local FRAME_TEXTURE_ASCENSION =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkFrameAsc.tga"


local FRAME_OVERLAY_NORMAL =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkFrameOverlay.tga"

local FRAME_OVERLAY_ASCENSION =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkFrameAscOverlay.tga"

 
local orbTextures = {
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkChi1.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkChi2.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkChi3.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkChi4.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkChi5.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Monk\\FFMonkChi6.tga",
}

 
local function IsWindwalker()
    local spec = GetSpecialization()
    return spec == SPEC_MONK_WINDWALKER
end

local function HasAscension()
    return IsPlayerSpell(ASCENSION_SPELL_ID)
end

 
local frame = CreateFrame("Frame", "ChiTrackerFrame", UIParent)
frame:SetSize(275, 275)

local anchor = FFXIV_UI_Anchors.JobGauge
frame:SetParent(anchor)
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)

 
frame.base = frame:CreateTexture(nil, "BACKGROUND")
frame.base:SetAllPoints(frame)
frame.base:SetTexture(FRAME_TEXTURE_NORMAL)


 
frame.orbs = {}

for i = 1, 6 do
    local orb = frame:CreateTexture(nil, "ARTWORK")
    orb:SetSize(275, 275)
    orb:SetPoint("CENTER", frame, "CENTER", 0, 0)
    orb:SetTexture(orbTextures[i])
    orb:Hide()

    frame.orbs[i] = orb
end

 
local overlayFrame = CreateFrame("Frame", "OverlayFrame", UIParent)
overlayFrame:SetSize(275, 275)
overlayFrame:SetParent(anchor)
overlayFrame:SetPoint("CENTER", anchor, "CENTER", 0, 0)

overlayFrame.base = overlayFrame:CreateTexture(nil, "BACKGROUND")
overlayFrame.base:SetAllPoints(overlayFrame)
overlayFrame:SetFrameLevel(frame:GetFrameLevel() + 1)  
 
 
 
local MAX_CHI = 5

 
local function ConfigureForSpecAndTalents()
    if not IsWindwalker() then
        frame:Hide()
        overlayFrame:Hide()
        return
    end

    frame:Show()
    overlayFrame:Show()
    if HasAscension() then
        MAX_CHI = 6
        frame.base:SetTexture(FRAME_TEXTURE_ASCENSION)
        overlayFrame.base:SetTexture(FRAME_OVERLAY_ASCENSION)
    else
        MAX_CHI = 5
        frame.base:SetTexture(FRAME_TEXTURE_NORMAL)
        overlayFrame.base:SetTexture(FRAME_OVERLAY_NORMAL)
    end
end

 



local previousChi = nil
local gaugeFullSFX = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Gauge_Full.ogg"

local FADE_TIME = 0.15

local function UpdateChi()
    if not IsWindwalker() then return end

    local power = UnitPower("player", POWER_TYPE) or 0

    if previousChi == nil then
        previousChi = power
    end

    for i = 1, 6 do
        if i <= MAX_CHI and i <= power then
            frame.orbs[i]:Show()
            UIFrameFadeIn(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 1)
        else
            frame.orbs[i]:Hide()
            UIFrameFadeOut(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 0)
        end
    end

if power == MAX_CHI and previousChi < MAX_CHI then
    PlayGaugeSFX(gaugeFullSFX)
end

    previousChi = power
end

 
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
frame:RegisterEvent("SPELLS_CHANGED")


frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if event == "UNIT_POWER_UPDATE" then
        if unit == "player" and powerType == "CHI" then
            UpdateChi()
        end
        return
    end

    ConfigureForSpecAndTalents()
    UpdateChi()
end)
