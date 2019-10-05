--Falloff, Intensity, Radius, Colour.
local LightTweener = Class(function(self, inst)
	self.inst = inst
	self.light = nil

	--initial values
	self.i_falloff = nil
	self.i_intensity = nil
	self.i_radius = nil
	self.I_colour_r, self.i_colour_g, self.i_colour_b = nil

	--target values
	self.t_falloff = nil
	self.t_intensity = nil
	self.t_radius = nil
	self.t_colour_r, self.t_colour_g, self.t_colour_b = nil

	--function
	self.callback = nil --call @ end of tween

	self.time = nil
	self.timepassed = 0

	self.tweening = false

	self.inst:ListenForEvent("lighttweener_start", function() self.tweening = true end)
	self.inst:ListenForEvent("lighttweener_end ", function() self.tweening = false end)

end)

function LightTweener:EndTween()
	--Set all values to final values

	if not self.light then
		print("No light set in LightTweener. Stopping from EndTween().")
		return
	end

	if self.t_radius then
		self.light:SetRadius(self.t_radius)
	end

	if self.t_intensity then
		self.light:SetIntensity(self.t_intensity)
	end

	if self.t_falloff then
		self.light:SetFalloff(self.t_falloff)
	end

	if self.t_colour_r and self.t_colour_g and self.t_colour_b then
		self.light:SetColour(self.t_colour_r, self.t_colour_g, self.t_colour_b)
	end

	self.inst:StopUpdatingComponent(self)
	self.inst:PushEvent("lighttweener_end")
	self.tweening = false
	
	if self.callback then
		self.callback(self.inst, self.light)
	end
end

local function UnpackColour(colour)
	if colour == nil or #colour <3 then
		return nil,nil,nil
	end
	return colour[1], colour[2], colour[3]
end

function LightTweener:StartTween(light, rad, intensity, falloff, colour, time, callback)
	if light then
		self.light = light
	end

	if not self.light then
		print("No light set in LightTweener. Stopping from StartTween().")
		return
	end

	self.callback = callback

	self.i_radius = self.light:GetRadius() or rad
	self.i_falloff = self.light:GetFalloff() or falloff
	self.i_intensity = self.light:GetIntensity() or intensity

	local i_colour = {self.light:GetColour()}
	if #i_colour > 0 then
		self.i_colour_r, self.i_colour_g, self.i_colour_b = UnpackColour(i_colour)
	else
		self.i_colour_r, self.i_colour_g, self.i_colour_b = UnpackColour(colour)
	end

	self.t_radius = rad
	self.t_intensity = intensity
	self.t_falloff = falloff
	self.t_colour_r, self.t_colour_g, self.t_colour_b = UnpackColour(colour)

	self.time = time
	self.timepassed = 0
	self.inst:PushEvent("lighttweener_start")	

	if self.time > 0 then
		self.inst:StartUpdatingComponent(self)
	else
		self:EndTween()
	end
end

function LightTweener:OnUpdate(dt)
	if not self.light then
		print("No light set in LightTweener. Stopping from OnUpdate().")
		self.inst:StopUpdatingComponent(self)
		return
	end

	self.timepassed = self.timepassed + dt
	local t = self.timepassed/self.time

	if self.i_radius and self.t_radius then
		self.light:SetRadius(Lerp(self.i_radius, self.t_radius, t))
	end

	if self.i_intensity and self.t_intensity then
		self.light:SetIntensity(Lerp(self.i_intensity, self.t_intensity, t))
	end

	if self.i_falloff and self.t_falloff then
		self.light:SetFalloff(Lerp(self.i_falloff, self.t_falloff, t))
	end

	if self.i_colour_r and self.t_colour_r and self.i_colour_g and self.t_colour_g and self.i_colour_b and self.t_colour_b then
		self.light:SetColour(
			Lerp(self.i_colour_r, self.t_colour_r, t), 
			Lerp(self.i_colour_g, self.t_colour_g, t), 
			Lerp(self.i_colour_b, self.t_colour_b, t))
	end

	if self.timepassed >= self.time then
		self:EndTween()
	end
end

return LightTweener