local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
require "os"

local DLCUpgrade = Class(Widget, function(self, owner)
    Widget._ctor(self, "DLCUpgrade")
    self.owner = owner

    if PLATFORM ~= "PS4" then
        self.button = self:AddChild(ImageButton("images/upgradepanels.xml", "DLC_all_promo_button.tex", "DLC_all_promo_button_rollover.tex"))
    else
        if APP_REGION == "SCEE" then
           self.button = self:AddChild(ImageButton("images/fepanels_ps4.xml", "DLC_all_promo_PS4_button2.tex", "DLC_all_promo_PS4_button2.tex"))
        else
           self.button = self:AddChild(ImageButton("images/fepanels_ps4.xml", "DLC_all_promo_PS4_button.tex", "DLC_all_promo_PS4_button.tex"))
        end
    end

    self.button:SetOnClick(self.OnClick)
    MainMenuStatsAdd("seen_dlc_upgrade")
    SendMainMenuStats()
end)

local steamlink = "http://store.steampowered.com/dlc/219740/"
local kleilink = "http://bit.ly/buy-ds-dlc"

local function GetLink()
    return PLATFORM == "WIN32_STEAM" and steamlink or kleilink
end

function DLCUpgrade:OnClick()
    --Set Metric!
    MainMenuStatsAdd("click_dlc_upgrade")
    SendMainMenuStats()
    VisitURL(GetLink())
end

return DLCUpgrade