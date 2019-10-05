local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"

local RunningProfilePopup = Class(Screen, function(self, duration, cb)
    Screen._ctor(self, "RunningProfilePopup")

    --darken everything behind the dialog
    --self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    --self.black:SetVRegPoint(ANCHOR_MIDDLE)
    --self.black:SetHRegPoint(ANCHOR_MIDDLE)
    --self.black:SetVAnchor(ANCHOR_MIDDLE)
    --self.black:SetHAnchor(ANCHOR_MIDDLE)
    --self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    --self.black:SetTint(0,0,0,.75)

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_TOP)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.frames = 0 -- need to delay a couple frames so the save can complete before DT starts ticking down.
    self.time = duration

    --text
    self.text = self.proot:AddChild(Text(TITLEFONT, 55))
    self.text:SetPosition(0, -50, 0)
    self.text:SetSize(55)
    self.text:SetString(string.format(STRINGS.UI.BUGREPORTSCREEN.RUNNING_PROFILE, math.ceil(self.time)))
    -- self.text:SetRegionSize(140, 100)
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:SetColour(1,1,1,1)

    self.cb = cb
end)

function RunningProfilePopup:OnUpdate( dt )
	if self.frames < 10 then
		--nothing
	elseif self.frames == 10 then
		TheSim:ToggleFrameProfiler(true)
	else
		self.time = self.time - dt
		self.text:SetString(string.format(STRINGS.UI.BUGREPORTSCREEN.RUNNING_PROFILE, math.ceil(self.time)))

		if self.time <= 0 then
			TheSim:ToggleFrameProfiler(false)
			TheFrontEnd:PopScreen()
			self.cb()
		end
	end
	self.frames = self.frames + 1
end

return RunningProfilePopup
