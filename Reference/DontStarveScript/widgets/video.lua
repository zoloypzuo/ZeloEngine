local Widget = require "widgets/widget"

Video = Class(Widget, function(self)
    Widget._ctor(self, "Video")
    
    self.inst.entity:AddVideoWidget()    
end)

function Video:__tostring()
	return string.format("%s - %s:%s", self.name, self.atlas or "", self.texture or "")
end

function Video:SetSize(w, h)
    if type(w) == "number" then
        self.inst.VideoWidget:SetSize(w,h)
    else
        self.inst.VideoWidget:SetSize(w[1],w[2])
    end
end

function Video:GetSize()
    local w, h = self.inst.VideoWidget:GetSize()
    return w, h
end

function Video:ScaleToSize(w, h)
	local w0, h0 = self.inst.VideoWidget:GetSize()
	local scalex = w / w0
	local scaley = h / h0
	self:SetScale(scalex, scaley, 1)
end

function Video:SetTint(r,g,b,a)
    self.inst.VideoWidget:SetTint(r,g,b,a)
    self.tint = {r, g, b, a}
end
--[[
function Video:SetAlphaRange(min, max)
	self.inst.VideoWidget:SetAlphaRange(min, max)
end

function Video:SetFadeAlpha(a, skipChildren)
	if not self.can_fade_alpha then return end
	
    self.inst.VideoWidget:SetTint(self.tint[1], self.tint[2], self.tint[3], self.tint[4] * a)
    Widget.SetFadeAlpha( self, a, skipChildren )
end
function Video:SetUVScale(xScale, yScale)
	self.inst.VideoWidget:SetUVScale(xScale, yScale)
end
]]

function Video:SetVRegPoint(anchor)
    self.inst.VideoWidget:SetVAnchor(anchor)
end

function Video:SetHRegPoint(anchor)
    self.inst.VideoWidget:SetHAnchor(anchor)
end


function Video:Load(filename)
	return self.inst.VideoWidget:Load(filename)
end

function Video:Play()
	self.inst.VideoWidget:Play()
end

function Video:IsDone()
	return self.inst.VideoWidget:IsDone()
end

function Video:Pause()
	self.inst.VideoWidget:Pause()
end

function Video:Stop()
	self.inst.VideoWidget:Stop()
end




return Video
