--Falloff, Intensity, Radius, Colour.
local ColourTweener = Class(function(self, inst)
	self.inst = inst

	--initial values
	self.i_colour_r, self.i_colour_g, self.i_colour_b, self.i_alpha = nil, nil, nil, nil

	--target values
	self.t_colour_r, self.t_colour_g, self.t_colour_b, self.t_alpha = nil, nil, nil, nil

	--function
	self.callback = nil --call @ end of tween

	self.time = nil
	self.timepassed = 0

	self.tweening = false
end)

function ColourTweener:IsTweening()
	return self.tweening
end


function ColourTweener:EndTween()
	--Set all values to final values

	if self.t_colour_r and self.t_colour_g and self.t_colour_b and self.t_alpha then
		self.inst.AnimState:SetMultColour(self.t_colour_r, self.t_colour_g, self.t_colour_b, self.t_alpha)
	end

	if self.callback then
		self.callback(self.inst)
	end
	self.tweening = false
	self.inst:PushEvent("colourtweener_end")
	self.inst:StopUpdatingComponent(self)
end

local function UnpackColour(colour)
	if colour == nil or #colour <3 then
		return 1,1,1,1
	end
	return colour[1], colour[2], colour[3], colour[4]
end

function ColourTweener:StartTween(colour, time, callback)
	self.callback = callback

	local i_colour = {self.inst.AnimState:GetMultColour()}
	if #i_colour > 0 then
		self.i_colour_r, self.i_colour_g, self.i_colour_b, self.i_alpha = UnpackColour(i_colour)
	else
		self.i_colour_r, self.i_colour_g, self.i_colour_b, self.i_alpha = UnpackColour(colour)
	end

	self.t_colour_r, self.t_colour_g, self.t_colour_b, self.t_alpha = UnpackColour(colour)

	self.time = time
	self.timepassed = 0
	self.inst:PushEvent("colourtweener_start")	
	self.tweening = true
	if self.time > 0 then
		self.inst:StartUpdatingComponent(self)
	else
		self:EndTween()
	end
end

function ColourTweener:OnUpdate(dt)	
	self.timepassed = self.timepassed + dt
	local t = self.timepassed/self.time
	if t > 1 then
		t = 1
	end

	if self.i_colour_r and self.t_colour_r and
	 self.i_colour_g and self.t_colour_g and 
	 self.i_colour_b and self.t_colour_b and 
	 self.i_alpha and self.t_alpha then	 	 
		self.inst.AnimState:SetMultColour(
		Lerp(self.i_colour_r, self.t_colour_r, t), 
		Lerp(self.i_colour_g, self.t_colour_g, t), 
		Lerp(self.i_colour_b, self.t_colour_b, t),
		Lerp(self.i_alpha, self.t_alpha, t))
	end

	if self.timepassed >= self.time then
		self:EndTween()
	end
end

return ColourTweener