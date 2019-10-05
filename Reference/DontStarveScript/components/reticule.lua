--[[
Add this component to items that need a targetting reticule
during use with a controller. Creation of the reticule is handled by
playercontroller.lua equip and unequip events.
--]]
local Reticule = Class(function(self, inst)
	self.inst = inst
	self.targetpos = nil
	self.ease = false
	self.smoothing = 6.66
	self.targetfn = nil
	self.reticuleprefab = "reticule"
	self.reticule = nil
	self.validcolour = {204/255,131/255,57/255,.3}
	self.invalidcolour = {1,0,0,.3}

end)

function Reticule:CreateReticule()
	local reticule = SpawnPrefab(self.reticuleprefab)

	if not reticule then return end

	if self.targetfn then
		self.targetpos = self.targetfn()
	end

	if self.targetpos then
		reticule.Transform:SetPosition(self.targetpos:Get())
	end

	self.reticule = reticule

	self.inst:StartUpdatingComponent(self)
end

function Reticule:DestroyReticule()
	if not self.reticule then return end
	self.reticule:Remove()
	self.reticule = nil
	self.inst:StopUpdatingComponent(self)
end

function Reticule:OnUpdate(dt)
	if not self.targetfn then return end

	self.targetpos = self.targetfn()
	
	if not self.targetpos then return end

	local pt = self.reticule:GetPosition()
	local x,y,z = self.targetpos:Get()

	if self.ease then
		x = Lerp(pt.x, self.targetpos.x, dt*self.smoothing)
		y = Lerp(pt.y, self.targetpos.y, dt*self.smoothing)
		z = Lerp(pt.z, self.targetpos.z, dt*self.smoothing)		
	end
	
	local tile = GetWorld().Map:GetTileAtPoint(self.targetpos:Get())
    local passable = tile ~= GROUND.IMPASSABLE

    if not passable then
    	self.reticule.components.colourtweener:StartTween(self.invalidcolour, 0)
    	self.reticule.AnimState:ClearBloomEffectHandle()
    	self.reticule:Hide()
    else
    	self.reticule.components.colourtweener:StartTween(self.validcolour, 0)
    	self.reticule.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    	self.reticule:Show()
    end

	self.reticule.Transform:SetPosition(x,y,z)
end

return Reticule