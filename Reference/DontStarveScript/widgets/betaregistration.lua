local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
require "os"

local BetaRegistration = Class(Widget, function(self, owner)
    Widget._ctor(self, "BetaRegistration")
    self.owner = owner

    self.button = self:AddChild(ImageButton("images/fepanels_DSTbeta.xml", "DST_closedBeta_button.tex", "DST_closedBeta_button_over.tex"))
    self.button:SetOnClick(self.OnClick)
end)

local function GetLink()
    return "http://www.dontstarvetogether.com/"
end

function BetaRegistration:OnClick()
    VisitURL(GetLink())
end

return BetaRegistration