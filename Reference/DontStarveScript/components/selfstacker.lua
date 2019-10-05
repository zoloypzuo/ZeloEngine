--Accessed by the item-stacking gnome.

local SelfStacker = Class(function(self, inst)
    self.inst = inst

    self.searchradius = 20
    self.stackpartner = nil
    self.inst:AddTag("selfstacker")

end)

function SelfStacker:CanSelfStack()
	--Not in inventory, can be stacked
	return (self.inst.components.stackable and not self.inst.components.stackable:IsFull()) and 
	(self.inst.components.inventoryitem and not self.inst.components.inventoryitem:IsHeld()) and
	Vector3(self.inst.Physics:GetVelocity()):LengthSq() < 1 and not
	self.stackpartner
end

function SelfStacker:FindItemToStackWith()
	self.stackpartner = FindEntity(self.inst, self.searchradius, function(item) return item.prefab == self.inst.prefab and item.components.selfstacker:CanSelfStack() end, {"selfstacker"})
	if self.stackpartner then
		self.stackpartner.components.selfstacker.stackpartner = self.inst
	end

	return self.stackpartner
end

function SelfStacker:DoStack()
	if self:FindItemToStackWith() then
		local num = self.inst.components.stackable:RoomLeft()
		local to_combine = self.stackpartner.components.stackable:Get(num)
		self.inst.components.stackable:Put(to_combine)
	end
end

function SelfStacker:OnEntityWake()
	self.stackpartner = nil
	if self:CanSelfStack() then
		self.inst:DoTaskInTime(math.random() * .1, function() self:DoStack() end)
	end
end

return SelfStacker