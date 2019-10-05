local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
require "os"

local RoGUpgrade = Class(Widget, function(self, owner)
    Widget._ctor(self, "RoGUpgrade")
    self.owner = owner

    if PLATFORM ~= "PS4" then
        self.button = self:AddChild(ImageButton("images/upgradepanels.xml", "DLCpromo_button.tex", "DLCpromo_button_rollover.tex"))
    else
        if APP_REGION == "SCEE" then
           self.button = self:AddChild(ImageButton("images/fepanels_ps4.xml", "DLCpromo_PS4_button2.tex", "DLCpromo_PS4_button2.tex"))
        else
           self.button = self:AddChild(ImageButton("images/fepanels_ps4.xml", "DLCpromo_PS4_button.tex", "DLCpromo_PS4_button.tex"))
        end
    end
    self.button:SetOnClick(self.OnClick)
    MainMenuStatsAdd("seen_rog_upgrade")
    SendMainMenuStats()
end)

local steamlink = "http://store.steampowered.com/app/282470/"
local kleilink = "http://bit.ly/buy-rog"

local function GetLink()
    return PLATFORM == "WIN32_STEAM" and steamlink or kleilink
end

function RoGUpgrade:OnClick()
    --Set Metric!
    MainMenuStatsAdd("click_rog_upgrade")
    SendMainMenuStats()
    VisitURL(GetLink())
end

return RoGUpgrade