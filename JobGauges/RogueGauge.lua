--print("Rogue Combo Point Gauge Loaded")

local _, class = UnitClass("player")
if class ~= "ROGUE" then return end
local gaugeFullSFX = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Gauge_Full.ogg"
 local function PlayGaugeSFX(filePath)
    if FFXIV_UI_DB and FFXIV_UI_DB.sfxEnabled then
        FFXIV_UI_PlaySoundFile(filePath)
    end
end
local POWER_TYPE = Enum.PowerType.ComboPoints

 
local FRAME_TEXTURE_5 =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\FFRogueFrame"

local FRAME_TEXTURE_6 =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\FFRogueFrame6"

local FRAME_TEXTURE_7 =
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\FFRogueFrame7"

 
local orbTextures = {
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\RogueCombo1",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\RogueCombo2",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\RogueCombo3",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\RogueCombo4",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\RogueCombo5",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\RogueCombo6",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Rogue\\RogueCombo7",
}

 
local frame = CreateFrame("Frame", "ComboPointTrackerFrame", UIParent)
frame:SetSize(350, 350)

local anchor = FFXIV_UI_Anchors.JobGauge
frame:SetParent(anchor)
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)

frame.base = frame:CreateTexture(nil, "BACKGROUND")
frame.base:SetAllPoints(frame)

frame.orbs = {}

for i = 1, 7 do
    local orb = frame:CreateTexture(nil, "ARTWORK")
    orb:SetSize(350, 350)
    orb:SetPoint("CENTER", frame, "CENTER", 0, 0)
    orb:SetTexture(orbTextures[i])
    orb:Hide()
    frame.orbs[i] = orb
end
 
local MAX_COMBO_POINTS = 5

 
local function ConfigureComboPoints()
    local max = UnitPowerMax("player", POWER_TYPE) or 5

 
    if max < 5 then max = 5 end
    if max > 7 then max = 7 end

    if MAX_COMBO_POINTS == max then return end
    MAX_COMBO_POINTS = max

    if max == 5 then
        frame.base:SetTexture(FRAME_TEXTURE_5)
    elseif max == 6 then
        frame.base:SetTexture(FRAME_TEXTURE_6)
    elseif max == 7 then
        frame.base:SetTexture(FRAME_TEXTURE_7)
    end
end


local previousComboPoints = nil

local FADE_TIME = 0.15  

local function UpdateComboPoints()

    local points = UnitPower("player", POWER_TYPE) or 0

    if previousComboPoints == nil then
        previousComboPoints = points
    end

    for i = 1, 7 do
        if i <= MAX_COMBO_POINTS and i <= points then
            if not frame.orbs[i]:IsShown() or frame.orbs[i].fadingOut then
                
                UIFrameFadeIn(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 1)
                frame.orbs[i].fadingOut = nil
            end
        else
            if frame.orbs[i]:IsShown() and not frame.orbs[i].fadingOut then
                
                UIFrameFadeOut(frame.orbs[i], FADE_TIME, frame.orbs[i]:GetAlpha(), 0)
                frame.orbs[i].fadingOut = true
            end
        end
    end

    if points == MAX_COMBO_POINTS and previousComboPoints < MAX_COMBO_POINTS then
         PlayGaugeSFX(gaugeFullSFX)
    end

    previousComboPoints = points
end


 

 
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("UNIT_MAXPOWER")           
frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if event == "UNIT_POWER_UPDATE" then
        if unit == "player" and powerType == "COMBO_POINTS" then
            UpdateComboPoints()
        end
        return
    end

 

        ConfigureComboPoints()
    UpdateComboPoints()
end)
