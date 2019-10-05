ControlMinions = Class(BehaviourNode, function(self, inst) 
	BehaviourNode._ctor(self, "ControlMinions")
	self.inst = inst
	self.ms = inst.components.minionspawner
	self.radius = nil
	self.minionrange = 3.5
end)

function ControlMinions:GetClosestMinion(item, minions)
	
	

	local ptx, pty, ptz = item.Transform:GetWorldPosition()
	
	local closest = nil
	local closest_dist = nil

	local inrange = {}
	for k,v in pairs(minions) do
		if v ~= item then
			local x, y, z = v.Transform:GetWorldPosition()
			local dist = math.sqrt(distsq(ptx, ptz, x, z))
			if dist <= self.minionrange then
				if not closest or dist < closest_dist then
					closest = v
					closest_dist = dist
				end
			end
		end
	end

	return closest
end

function ControlMinions:CanActOn(item)
	return item:IsOnValidGround() and 
	item:GetTimeAlive() > 1 and 
	item:IsValid() and not 
	item:HasTag("irreplaceable") and not
	(item:HasTag("lureplant") or item:HasTag("eyeplant") or item:HasTag("notarget")) and not
	(item.components.inventoryitem and (item.components.container or item.components.inventoryitem:IsHeld())) and not
	(item.components.pickable and not (item.components.pickable:CanBePicked() or item.components.pickable.caninteractwith))
end


function ControlMinions:Visit()
	local minions = {}
	if self.status == READY then
		if self.ms.numminions > 0 then
			self.status = RUNNING
		else
			self.status = FAILED
		end
	end

	if self.status == RUNNING then

		if not self.radius then	--Get the distance you need to look for things within.
			if self.ms.minionpositions then
				local rad = math.sqrt(distsq(self.inst:GetPosition(), self.ms.minionpositions[#self.ms.minionpositions]))
				self.radius = rad + (rad * 0.1)
			end
		end

		if not self.radius then 
			self.status = FAILED
			return 
		end

		local pt = self.inst:GetPosition()
		local ents = nil
		if pt then
			ents = TheSim:FindEntities(pt.x, pt.y, pt.z, self.radius)	--find all entities within required radius
		end
		if ents and #ents > 0 then
			for k,v in pairs(ents) do
				if self:CanActOn(v) then
					local mn = self:GetClosestMinion(v, self.ms.minions)
					if mn and not mn.sg:HasStateTag("busy") then
						if (v.components.crop and v.components.crop:IsReadyForHarvest()) or
						   (v.components.stewer and v.components.stewer.done) or
            			   (v.components.dryer and v.components.dryer:IsDone()) then
            			   --Harvest!
            			   local ba = BufferedAction(mn,v,ACTIONS.HARVEST)
					       ba.distance = 4
					       mn:PushBufferedAction(ba)
            			elseif (v.components.pickable and v.components.pickable:CanBePicked() and v.components.pickable.caninteractwith) then
            				--Pick!
					        local ba = BufferedAction(mn,v,ACTIONS.PICK)
					        ba.distance = 4
					        mn:PushBufferedAction(ba)
            			elseif (v.components.inventoryitem and v.components.inventoryitem.cangoincontainer and not v.components.container and not v.components.inventoryitem:IsHeld()) then
            				--Pick up!
            				local ba = BufferedAction(mn,v,ACTIONS.PICKUP)
					        ba.distance = 4
					        mn:PushBufferedAction(ba)
            			end
            			local ba = mn:GetBufferedAction()
            			
            			if ba and ba.target and ba.target:IsValid() then
            				mn:ForceFacePoint(ba.target.Transform:GetWorldPosition())
               			end

					end			
				end
			end
			self.status = SUCCESS
		else
			self.status = FAILED
		end

	end

end