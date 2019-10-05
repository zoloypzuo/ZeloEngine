local Widget = require "widgets/widget"
require "widgets/image"

local Screen = Class(Widget, function(self, name)
    Widget._ctor(self, name)
	--self.focusstack = {}
	--self.focusindex = 0
	self.handlers = {}
end)

function Screen:GetHelpText()
	return ""
end

function Screen:OnDestroy()
	self:Kill()
end

function Screen:OnUpdate(dt)
	return true
end

function Screen:OnBecomeInactive()
	self.last_focus = self:GetDeepestFocus()
end

function Screen:OnBecomeActive()
	TheSim:SetUIRoot(self.inst.entity)
	if self.last_focus and self.last_focus.inst:IsValid() then
		self.last_focus:SetFocus()
	else
		self.last_focus = nil
		if self.default_focus then
			self.default_focus:SetFocus()
		end
	end
end

function Screen:AddEventHandler(event, fn)
	if not self.handlers[event] then
		self.handlers[event] = {}
	end
	
	self.handlers[event][fn] = true
	
	return fn
end

function Screen:RemoveEventHandler(event, fn)
	if self.handlers[event] then
		self.handlers[event][fn] = nil
	end
end

function Screen:HandleEvent(type, ...)
	local handlers = self.handlers[type]
	if handlers then
		for k,v in pairs(handlers) do
			k(...)
		end
	end
end

function Screen:SetDefaultFocus()
	if self.default_focus then
		self.default_focus:SetFocus()
		return true
	end
end

return Screen