--print("FFXIV UI Player HP loaded")

 
PlayerFrame:Hide()
hooksecurefunc(PlayerFrame, "Show", function(self)
    self:Hide()
end)

 local SCALE = 100
local function s(x) return x * SCALE / 100 end   


 
Playerframe_HP = CreateFrame("Frame", nil, UIParent)
local f = Playerframe_HP

f:SetSize(s(232), s(230))
f:SetFrameStrata("MEDIUM")

 local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Background")

 
local bar = CreateFrame("StatusBar", nil, f)
bar:SetPoint("TOPLEFT", s(4), s(-4))
bar:SetPoint("BOTTOMRIGHT", s(-4), s(4))
bar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Health")
bar:SetFrameLevel(f:GetFrameLevel() + 2)  

 
local cutawayBar = CreateFrame("StatusBar", nil, f)
cutawayBar:SetPoint("TOPLEFT", s(4), s(-4))
cutawayBar:SetPoint("BOTTOMRIGHT", s(-4), s(4))
cutawayBar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Cutaway")
cutawayBar:SetFrameLevel(f:GetFrameLevel() + 1)   

 

 
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

 
local hpLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
hpLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MiedingerMedium.ttf", s(18))
hpLabel:SetPoint("BOTTOMLEFT", outlineFrame, "BOTTOMLEFT", s(2), s(80))      
hpLabel:SetJustifyH("LEFT")
hpLabel:SetDrawLayer("OVERLAY", 7)
hpLabel:SetText("HP")
hpLabel:SetTextColor(252/255, 251/255, 250/255)       
hpLabel:SetShadowColor(0.8196, 0.7804, 0.6980)        
hpLabel:SetShadowOffset(0, -1)
 
local CLICK_RECT_WIDTH  = s(240)
local CLICK_RECT_HEIGHT = s(48)
local clickFrame = CreateFrame("Button", nil, outlineFrame, "SecureUnitButtonTemplate")

clickFrame:SetFrameStrata("MEDIUM")
clickFrame:SetFrameLevel(outlineFrame:GetFrameLevel() + 10)
clickFrame:SetSize(CLICK_RECT_WIDTH, CLICK_RECT_HEIGHT)
clickFrame:SetPoint("CENTER", outlineFrame, "CENTER", 0, s(-10))
clickFrame:EnableMouse(true)
clickFrame:RegisterForClicks("AnyUp")
clickFrame:SetAttribute("unit", "player")
clickFrame:SetAttribute("type1", "target")
clickFrame:SetAttribute("type2", "togglemenu")

 
local combatTexture = f:CreateTexture(nil, "OVERLAY")
combatTexture:SetSize(s(105), s(105))
combatTexture:SetPoint("LEFT", f, "LEFT", -35, s(15))
combatTexture:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\FFInCombat")
combatTexture:Hide()   

local outOfCombatTexture = f:CreateTexture(nil, "OVERLAY")
outOfCombatTexture:SetSize(s(105), s(105))
outOfCombatTexture:SetPoint("LEFT", f, "LEFT", -35, s(15))
outOfCombatTexture:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\FFOutOfCombat")
outOfCombatTexture:Show()   

 
local anchor = FFXIV_UI_Anchors.PlayerHP
f:SetParent(anchor)
f:ClearAllPoints()
f:SetPoint("CENTER", anchor, "CENTER", 0, 0)



 
local function UpdateCombatTextures(inCombat)
    if inCombat then
        combatTexture:Show()
        outOfCombatTexture:Hide()
    else
        combatTexture:Hide()
        outOfCombatTexture:Show()
    end
end

 
local function Update()
    local hp = UnitHealth("player")
    local maxHp = UnitHealthMax("player")
 
    bar:SetMinMaxValues(0, maxHp)
    bar:SetValue(hp, Enum.StatusBarInterpolation.ExponentialEaseOut)
    text:SetText(hp)


    cutawayBar:SetMinMaxValues(0, maxHp)
    cutawayBar:SetValue(hp, Enum.StatusBarInterpolation.ExponentialEaseOut)

end

 
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterUnitEvent("UNIT_HEALTH", "player")
f:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
f:RegisterEvent("PLAYER_REGEN_DISABLED")  
f:RegisterEvent("PLAYER_REGEN_ENABLED")   
f:RegisterEvent("PLAYER_LOGIN")

 
f:SetScript("OnEvent", function(_, event, unit)

    if event == "PLAYER_LOGIN" then
        Update()
        UpdateCombatTextures(InCombatLockdown())
        return
    end

    if event == "PLAYER_REGEN_DISABLED" then
        UpdateCombatTextures(true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        UpdateCombatTextures(false)
    end

    if unit == "player" then
        Update()
    end
end)

 
 
