local Placer = Class(function(self, inst)
    self.inst = inst
	self.can_build = false
	self.radius = 1
	self.inst:AddTag("NOCLICK")
end)

function Placer:SetBuilder(builder, recipe, invobject)
	self.builder = builder
	self.recipe = recipe
	self.invobject = invobject
	self.inst:StartUpdatingComponent(self)
	
end

function Placer:GetDeployAction()
	if self.invobject then
		return BufferedAction(self.builder, nil, ACTIONS.DEPLOY, self.invobject, Vector3(self.inst.Transform:GetWorldPosition()))	
	end
end

function Placer:getOffset()
	local offset = 1
	if self.recipe then 
		if self.recipe.distance then 
			offset = self.recipe.distance - 1
			offset = math.max(offset, 1)
		end 
	elseif self.invobject then 
		if self.invobject.components.deployable and self.invobject.components.deployable.deploydistance then 
			offset = self.invobject.components.deployable.deploydistance
		end 
	end 	
	return offset
end

function Placer:OnUpdate(dt)
	if not TheInput:ControllerAttached() then
		local pt = Input:GetWorldPosition()
		if self.snap_to_tile and GetWorld().Map then
			pt = Vector3(GetWorld().Map:GetTileCenterPoint(pt:Get()))
		elseif self.snap_to_meters then
			pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
		end
		self.inst.Transform:SetPosition(pt:Get())	
	else
		if self.snap_to_tile and GetWorld().Map then
			--Using an offset in this causes a bug in the terraformer functionality while using a controller.
			local pt = Vector3(GetPlayer().entity:LocalToWorldSpace(0,0,0))
			pt = Vector3(GetWorld().Map:GetTileCenterPoint(pt:Get()))
			self.inst.Transform:SetPosition(pt:Get())
		elseif self.snap_to_meters then
			local pt = Vector3(GetPlayer().entity:LocalToWorldSpace(1,0,0))
			pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
			self.inst.Transform:SetPosition(pt:Get())
		else
			if self.inst.parent == nil then
				GetPlayer():AddChild(self.inst)
				self.inst.Transform:SetPosition(1,0,0)
			end
		end
	end
	

	self.can_build = true

	if self.placeTestFn then
		local inputPt = Input:GetWorldPosition()

		if TheInput:ControllerAttached() then
			local offset = self:getOffset()
			inputPt =  Vector3(GetPlayer().entity:LocalToWorldSpace(offset, 0, 0))
		end

		local pt = self.selected_pos or inputPt	
	
		self.can_build = self.placeTestFn(self.inst, pt)
		self.targetPos = self.inst:GetPosition()
	end

	if self.testfn then
		self.can_build = self.testfn(Vector3(self.inst.Transform:GetWorldPosition()))
	end
	
	--self.inst.AnimState:SetMultColour(0,0,0,.5)
	
	local color = self.can_build and Vector3(.25,.75,.25) or Vector3(.75,.25,.25)
	self.inst.AnimState:SetAddColour(color.x, color.y, color.z ,1)
	
end

return Placer
