local Discoverable = Class(function(self, inst)
    self.inst = inst
    self.discovered = false

	self.undiscoveredIcon = nil
	self.discoveredIcon = nil

	inst:ListenForEvent( "onclick",
		function( globa, data )
			if not self.discovered then
				self:Discover()
			end
		end
	)
end)

function Discoverable:Discover()
	self.discovered = true

	self.inst.MiniMapEntity:SetIcon( self.discoveredIcon )
	--self.inst.MiniMapEntity:SetRenderOnTopOfMask( false )
end

function Discoverable:Hide()
	self.discovered = false

	self.inst.MiniMapEntity:SetIcon( self.undiscoveredIcon )
	--self.inst.MiniMapEntity:SetRenderOnTopOfMask( true )
end

function Discoverable:SetIcons(undiscovered, discovered)
	self.undiscoveredIcon = undiscovered
	self.discoveredIcon = discovered

	self:Hide()
end

function Discoverable:OnSave(data)
	local data = {}

	if self.discovered then
		data.discovered = true
	end

	return data
end

function Discoverable:OnLoad(data)
	if data.discovered then
		self:Discover()
	end
end

return Discoverable

