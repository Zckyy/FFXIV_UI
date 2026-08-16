--print("Evoker Essence Gauge Loaded")

local _, class = UnitClass("player")
if class ~= "EVOKER" then return end

local ADDON_NAME = ...
local POWER_TYPE = Enum.PowerType.Essence

local POWER_NEXUS_SPELL_ID = 369908 
local gaugeFullSFX = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Gauge_Full.ogg"   

local FRAME_TEXTURE_NORMAL =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Evoker\\FFEvokerFrame.tga"

local FRAME_TEXTURE_POWER_NEXUS =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Evoker\\FFEvokerFrame6.tga"

local orbTextures = {
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Evoker\\FFEssence1.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Evoker\\FFEssence2.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Evoker\\FFEssence3.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Evoker\\FFEssence4.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Evoker\\FFEssence5.tga",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Evoker\\FFEssence6.tga",
}


local function HasPowerNexus()
    return IsPlayerSpell(POWER_NEXUS_SPELL_ID)
end
local function PlayGaugeSFX(filePath)
    if not FFXIV_UI_DB or not FFXIV_UI_DB.sfxEnabled then return end
    FFXIV_UI_PlaySoundFile(filePath)
end

local frame = CreateFrame("Frame", "EssenceTrackerFrame", UIParent)
frame:SetSize(375, 375)

local anchor = FFXIV_UI_Anchors.JobGauge
frame:SetParent(anchor)
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)


frame.base = frame:CreateTexture(nil, "BACKGROUND")
frame.base:SetAllPoints(frame)
frame.base:SetTexture(FRAME_TEXTURE_NORMAL)


frame.orbs = {}
for i = 1, 6 do
    local orb = frame:CreateTexture(nil, "ARTWORK")
    orb:SetSize(375, 375)
    orb:SetPoint("CENTER", frame, "CENTER", 0, 0)
    orb:SetTexture(orbTextures[i])
    orb:Hide()
    frame.orbs[i] = orb
end

local MAX_ESSENCE = 5
local previousPower = nil

local function ConfigureForTalents()
    if HasPowerNexus() then
        MAX_ESSENCE = 6
        frame.base:SetTexture(FRAME_TEXTURE_POWER_NEXUS)
    else
        MAX_ESSENCE = 5
        frame.base:SetTexture(FRAME_TEXTURE_NORMAL)
    end
end

local FADE_TIME = 0.15 

local function UpdateEssence()
    local power = UnitPower("player", POWER_TYPE)

     
    if previousPower == nil then
        previousPower = power
    end

    for i = 1, 6 do
        if i <= MAX_ESSENCE and i <= power then
            if not frame.orbs[i]:IsShown() or frame.orbs[i].fadingOut then
                frame.orbs[i].fadingOut = nil
                UIFrameFadeIn(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 1)
            end
        else
            if frame.orbs[i]:IsShown() and not frame.orbs[i].fadingOut then
                frame.orbs[i].fadingOut = true
                UIFrameFadeOut(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 0)
            end
        end
    end

 
    if power == MAX_ESSENCE and previousPower < MAX_ESSENCE then
        PlayGaugeSFX(gaugeFullSFX)
    end

    previousPower = power
end



frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
frame:RegisterEvent("SPELLS_CHANGED")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if event == "UNIT_POWER_UPDATE" then
        if unit == "player" and powerType == "ESSENCE" then
            UpdateEssence()
        end
        return
    end

    ConfigureForTalents()
    UpdateEssence()
end)
