--print("Feral Gauge Loaded")

local _, class = UnitClass("player")
if class ~= "DRUID" then return end

local MAX_COMBO_POINTS = 5
local POWER_TYPE = 4  
local FADE_TIME = 0.2

local gaugeFullSFX = "Interface\\AddOns\\FFXIV_UI\\Media\\Audio\\FFXIV_Gauge_Full.ogg"
local function PlayGaugeSFX(filePath)
    if FFXIV_UI_DB and FFXIV_UI_DB.sfxEnabled then
        FFXIV_UI_PlaySoundFile(filePath)
    end
end
 
local frame = CreateFrame("Frame", "ComboTrackerFrame", UIParent)
frame:SetSize(350, 350)

local anchor = FFXIV_UI_Anchors.JobGauge
frame:SetParent(anchor)
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)

frame.base = frame:CreateTexture(nil, "BACKGROUND")
frame.base:SetAllPoints(frame)
frame.base:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Druid\\FeralGauge")

frame.orbs = {}
frame.currentPoints = 0

local orbTextures = {
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Druid\\FeralCombo1",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Druid\\FeralCombo2",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Druid\\FeralCombo3",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Druid\\FeralCombo4",
    "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\JobGauges\\Druid\\FeralCombo5",
}

for i = 1, MAX_COMBO_POINTS do
    local orb = frame:CreateTexture(nil, "ARTWORK")
    orb:SetSize(350, 350)
    orb:SetPoint("CENTER", frame, "CENTER", 0, 0)
    orb:SetTexture(orbTextures[i])
    orb:SetAlpha(0)
    orb:Hide()
    frame.orbs[i] = orb
end

local function InCatForm()
    return GetShapeshiftForm() == 2
end

local function FadeInOrb(orb)
    orb:Show()
    UIFrameFadeIn(orb, FADE_TIME, orb:GetAlpha(), 1)
end

local function FadeOutOrb(orb)
    UIFrameFadeOut(orb, FADE_TIME, orb:GetAlpha(), 0)
    C_Timer.After(FADE_TIME, function()
        if orb:GetAlpha() == 0 then
            orb:Hide()
        end
    end)
end

local function UpdateVisibility()
    if InCatForm() then
        frame:Show()
    else
        frame:Hide()
    end
end

local previousFeralPoints = nil

local function UpdateComboPoints()
    if not InCatForm() then return end

    local comboPoints = UnitPower("player", POWER_TYPE) or 0

    if previousFeralPoints == nil then
        previousFeralPoints = comboPoints
    end

    if comboPoints ~= frame.currentPoints then
        for i = 1, MAX_COMBO_POINTS do
            if i <= comboPoints and i > frame.currentPoints then
                FadeInOrb(frame.orbs[i])
            elseif i > comboPoints and i <= frame.currentPoints then
                FadeOutOrb(frame.orbs[i])
            end
        end
    end

if comboPoints == MAX_COMBO_POINTS and previousFeralPoints < MAX_COMBO_POINTS then
    PlayGaugeSFX(gaugeFullSFX)
end

    frame.currentPoints = comboPoints
    previousFeralPoints = comboPoints
end

frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

frame:SetScript("OnEvent", function(self, event, unit, powerType)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateVisibility()
        UpdateComboPoints()
    elseif event == "UPDATE_SHAPESHIFT_FORM" then
        UpdateVisibility()
        UpdateComboPoints()
    elseif event == "UNIT_POWER_UPDATE" and unit == "player" and powerType == "COMBO_POINTS" then
        UpdateComboPoints()
    end
end)

UpdateVisibility()
UpdateComboPoints()
