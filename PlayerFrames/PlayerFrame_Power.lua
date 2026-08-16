--print("FFXIV UI Player Power loaded")


local SCALE = 100
local function s(x) return x * SCALE / 100 end  


PlayerFrame_Power = CreateFrame("Frame", nil, UIParent)
local f = PlayerFrame_Power

f:SetSize(s(232), s(230))

f:SetFrameStrata("MEDIUM")



local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Background")


local bar = CreateFrame("StatusBar", nil, f)
bar:SetPoint("TOPLEFT", s(4), s(-4))
bar:SetPoint("BOTTOMRIGHT", s(-4), s(4))
bar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Health")

local tex = bar:GetStatusBarTexture()
tex:SetDrawLayer("ARTWORK", 0)
tex:SetTexCoord(0.5, 1, 0, 1)

local outlineFrame = CreateFrame("Frame", nil, f)
outlineFrame:SetFrameStrata("MEDIUM")
outlineFrame:SetFrameLevel(f:GetFrameLevel() + 5)
outlineFrame:SetSize(f:GetWidth(), f:GetHeight())
outlineFrame:SetPoint("CENTER", f, "CENTER")
outlineFrame:EnableMouse(false)

local outline = outlineFrame:CreateTexture(nil, "OVERLAY")
outline:SetAllPoints()
outline:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Frame")
outline:SetDrawLayer("OVERLAY", 3)

local text = outlineFrame:CreateFontString(nil, "OVERLAY")
text:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtended.ttf", s(30))
text:SetPoint("BOTTOMRIGHT", outlineFrame, "BOTTOMRIGHT", s(-4), s(76))
text:SetJustifyH("RIGHT")
text:SetDrawLayer("OVERLAY", 7)
text:SetTextColor(252/255, 251/255, 250/255)
text:SetShadowColor(0.8196, 0.7804, 0.6980)
text:SetShadowOffset(0, -1)


local powerLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
powerLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MiedingerMedium.ttf", s(18))
powerLabel:SetPoint("BOTTOMLEFT", outlineFrame, "BOTTOMLEFT", s(2), s(80))
powerLabel:SetJustifyH("LEFT")
powerLabel:SetDrawLayer("OVERLAY", 7)
powerLabel:SetText("MP")
powerLabel:SetTextColor(252/255, 251/255, 250/255)
powerLabel:SetShadowColor(0.8196, 0.7804, 0.6980)
powerLabel:SetShadowOffset(0, -1)


local defaultTexture = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Mana"
local furyTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Fury"  
local rageTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Rage"
local astralPowerTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\AstralPower"
local energyTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Energy"
local insanityTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Insanity"
local manaTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Mana"
local runicPowerTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\RunicPower"
local focusTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Focus"
local maelstromTexture   = "Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Maelstrom"

local anchor = FFXIV_UI_Anchors.PlayerPower
f:SetParent(anchor)
f:ClearAllPoints()
f:SetPoint("CENTER", anchor, "CENTER", 0, 0)

local lastPower
local lastPowerType

local function Update()
    local powerType, powerToken = UnitPowerType("player") 
    local power = UnitPower("player", powerType)
    local maxPower = UnitPowerMax("player", powerType)

    lastPower = power
    lastPowerType = powerType

    bar:SetMinMaxValues(0, maxPower)
    bar:SetValue(power, Enum.StatusBarInterpolation.ExponentialEaseOut)

    if powerToken == "FURY" then
        bar:SetStatusBarTexture(furyTexture)
        powerLabel:SetText("FP")

    elseif powerToken == "MANA" then
        bar:SetStatusBarTexture(manaTexture)
        powerLabel:SetText("MP")

    elseif powerToken == "RAGE" then
        bar:SetStatusBarTexture(rageTexture)
        powerLabel:SetText("RP")

    elseif powerToken == "ENERGY" then
        bar:SetStatusBarTexture(energyTexture)
        powerLabel:SetText("EP")

    elseif powerToken == "INSANITY" then
        bar:SetStatusBarTexture(insanityTexture)
        powerLabel:SetText("IP")

    elseif powerToken == "LUNAR_POWER" then
        bar:SetStatusBarTexture(astralPowerTexture)
        powerLabel:SetText("AP")
    
    elseif powerToken == "RUNIC_POWER" then
        bar:SetStatusBarTexture(runicPowerTexture)
        powerLabel:SetText("RP")

    elseif powerToken == "FOCUS" then
        bar:SetStatusBarTexture(focusTexture)
        powerLabel:SetText("FP")

   elseif powerToken == "MAELSTROM" then
        bar:SetStatusBarTexture(maelstromTexture)
        powerLabel:SetText("MS")

    else
        bar:SetStatusBarTexture(defaultTexture)
        powerLabel:SetText(powerToken)
    end

    local tex = bar:GetStatusBarTexture()
    tex:SetDrawLayer("ARTWORK", 0)
    tex:SetTexCoord(0.5, 1, 0, 1)

    text:SetText(power)
end

local function PollPlayerPower()
    local powerType = UnitPowerType("player")
    local power = UnitPower("player", powerType)

    if powerType ~= lastPowerType or power ~= lastPower then
        Update()
    end
end

local function ConfigurePowerUpdateEvent()
    f:UnregisterEvent("UNIT_POWER_UPDATE")
    f:UnregisterEvent("UNIT_POWER_FREQUENT")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

    if FFXIV_UI_DB and FFXIV_UI_DB.fastBarUpdates then
        f:SetScript("OnUpdate", PollPlayerPower)
    else
        f:SetScript("OnUpdate", nil)
    end
end

function FFXIV_UI_UpdatePlayerPower()
    ConfigurePowerUpdateEvent()
    Update()
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
f:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")

f:SetScript("OnEvent", function(_, event, unit)
    if not unit or unit == "player" then
        Update()
    end
end)

FFXIV_UI_UpdatePlayerPower()

 
