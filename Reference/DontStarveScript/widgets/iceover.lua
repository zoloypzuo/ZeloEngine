local Widget = require "widgets/widget"
local Image = require "widgets/image"


local IceOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "IceOver")
	self:SetClickable(false)

	self.img = self:AddChild(Image("images/fx.xml", "ice_over.tex"))
	self.img:SetEffect( "shaders/uifade.ksh" )
    self.img:SetHAnchor(ANCHOR_MIDDLE)
    self.img:SetVAnchor(ANCHOR_MIDDLE)
    self.img:SetScaleMode(SCALEMODE_FILLSCREEN)

    self:Hide()
    self.laststep = 0
    
    self.alpha_min = 1
    self.alpha_min_target = 1
    
    self.inst:ListenForEvent("temperaturedelta", function(inst, data) self:OnIceChange() end, self.owner)
end)


function IceOver:OnIceChange()
	
	local temp = self.owner.components.temperature:GetCurrent()

	local num_steps = 4
	
	
	local all_up_thresh = {5, 0, -5, -10}
	
	local freeze_sounds = 
	{
		"dontstarve/winter/freeze_1st",
		"dontstarve/winter/freeze_2nd",
		"dontstarve/winter/freeze_3rd",
		"dontstarve/winter/freeze_4th",
	}
	local freeze_sounds_names =
	{
		"freeze_1st",
		"freeze_2nd",
		"freeze_3rd",
		"freeze_4th",
	}
	--local all_down_thresh = {8, 3, -2, -7}
	
	local up_thresh = all_up_thresh[self.laststep+1]
	local down_thresh = all_up_thresh[self.laststep]

	if up_thresh and temp < up_thresh and self.laststep < num_steps and (temp <= 5 or GetSeasonManager():IsWinter()) then
		if not TheFrontEnd:GetSound():PlayingSound(freeze_sounds_names[self.laststep+1]) then
			TheFrontEnd:GetSound():PlaySound(freeze_sounds[self.laststep+1], freeze_sounds_names[self.laststep+1])
		end
		self.laststep = self.laststep + 1
	elseif down_thresh and temp > down_thresh and self.laststep > 0 then
		self.laststep = self.laststep - 1
	end
	
	if self.laststep == 0 then
		self.alpha_min_target = 1
	else
		
		local alpha_mins = {
			.7, .5, .3, 0
		}
		self.alpha_min_target = alpha_mins[self.laststep] 

		self:StartUpdating()
	end


end

function IceOver:OnUpdate(dt)
	local lspeed = dt*2
	self.alpha_min = (1 - lspeed) * self.alpha_min + lspeed *self.alpha_min_target
	self.img:SetAlphaRange(self.alpha_min,1)
	
	if self.alpha_min >= .99 then
		self:Hide()
		self:StopUpdating()
	else
		self:Show()
	end
end

return IceOver