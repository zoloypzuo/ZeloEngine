local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
require "os"

local ShipwreckedUpgrade = Class(Widget, function(self, owner)
    Widget._ctor(self, "ShipwreckedUpgrade")
    self.owner = owner

    if PLATFORM ~= "PS4" then
        self.button = self:AddChild(ImageButton("images/upgradepanels.xml", "DLC_shipwrecked_promo_button.tex", "DLC_shipwrecked_promo_button_rollover.tex"))
    else
        if APP_REGION == "SCEE" then
           self.button = self:AddChild(ImageButton("images/fepanels_ps4.xml", "DLC_shipwrecked_promo_PS4_button2.tex", "DLC_shipwrecked_promo_PS4_button2.tex"))
        else
           self.button = self:AddChild(ImageButton("images/fepanels_ps4.xml", "DLC_shipwrecked_promo_PS4_button.tex", "DLC_shipwrecked_promo_PS4_button.tex"))
        end
    end
    self.button:SetOnClick(self.OnClick)
    MainMenuStatsAdd("seen_shipwrecked_upgrade")
    SendMainMenuStats()
end)

local steamlink = "http://store.steampowered.com/app/393010/"
local kleilink = "http://bit.ly/buy-sw"

local function GetLink()
    return PLATFORM == "WIN32_STEAM" and steamlink or kleilink
end

function ShipwreckedUpgrade:OnClick()
    --Set Metric!
    MainMenuStatsAdd("click_shipwrecked_upgrade")
    SendMainMenuStats()
    VisitURL(GetLink())
end

return ShipwreckedUpgrade