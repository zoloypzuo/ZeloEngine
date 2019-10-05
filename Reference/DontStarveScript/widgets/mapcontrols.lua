local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local PauseScreen = require "screens/pausescreen"

--require "screens/mapscreen"

--base class for imagebuttons and animbuttons. 
local MapControls = Class(Widget, function(self)
	Widget._ctor(self, "Map Controls")
    local MAPSCALE = .5
	self.minimapBtn = self:AddChild(ImageButton(HUD_ATLAS, "map_button.tex"))
    self.minimapBtn:SetScale(MAPSCALE,MAPSCALE,MAPSCALE)
	self.minimapBtn:SetOnClick( function() self:ToggleMap() end )
	self.minimapBtn:SetTooltip(STRINGS.UI.HUD.MAP)


	
	self.pauseBtn = self:AddChild(ImageButton(HUD_ATLAS, "pause.tex"))
	self.pauseBtn:SetTooltip(STRINGS.UI.HUD.PAUSE)
	self.pauseBtn:SetScale(.33,.33,.33)
	self.pauseBtn:SetPosition( Point( 0,-50,0 ) )
	
    self.pauseBtn:SetOnClick(
		function()
			if not IsPaused() then
				TheFrontEnd:PushScreen(PauseScreen())
			end
		end )


	self.rotleft = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex"))
    self.rotleft:SetPosition(-40,-40,0)
    self.rotleft:SetScale(-.7,.7,.7)
    self.rotleft:SetOnClick(function() GetPlayer().components.playercontroller:RotLeft() end)
    self.rotleft:SetTooltip(STRINGS.UI.HUD.ROTLEFT)

	self.rotright = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex"))
    self.rotright:SetPosition(40,-40,0)
    self.rotright:SetScale(.7,.7,.7)
    self.rotright:SetOnClick(function() GetPlayer().components.playercontroller:RotRight() end)
	self.rotright:SetTooltip(STRINGS.UI.HUD.ROTRIGHT)	

end)

function MapControls:ToggleMap()
	GetPlayer().HUD.controls:ToggleMap()
end

return MapControls
