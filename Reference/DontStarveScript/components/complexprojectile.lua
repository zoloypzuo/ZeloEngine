local ComplexProjectile = Class(function(self, inst)
	self.inst = inst

	self.velocity = Vector3(0,0,0)
	self.gravity = -9.81

	self.hoizontalSpeed = 4

	self.onlaunchfn = nil
	self.onhitfn = nil
	self.onmissfn = nil

end)

function ComplexProjectile:GetDebugString()
	return tostring(self.velocity)
end

function ComplexProjectile:SetHorizontalSpeed(speed)
    self.horizontalSpeed = speed
end

function ComplexProjectile:SetLaunchOffset(offset)
    self.launchoffset = offset -- x is facing, y is height, z is ignored
end

function ComplexProjectile:SetOnLaunch(fn)
	self.onlaunchfn = fn
end

function ComplexProjectile:SetOnHit(fn)
	self.onhitfn = fn
end

function ComplexProjectile:GetVerticalVelocity(distance)
	return ((self.gravity * distance)/2)/self.hoizontalSpeed
end

function ComplexProjectile:CalculateTrajectory(startPos, endPos, speed)
    local speedSq = speed * speed
    local g = -self.gravity

    local dx = endPos.x - startPos.x
    local dy = endPos.y - startPos.y
    local dz = endPos.z - startPos.z

    local rangeSq = dx * dx + dz * dz
    local range = math.sqrt(rangeSq)
    local discriminant = speedSq * speedSq - g * (g * rangeSq + 2 * dy * speedSq)
    local angle
    if discriminant >= 0 then
        local discriminantSqrt = math.sqrt(discriminant)
        local gXrange = g * range
        local angleA = math.atan((speedSq - discriminantSqrt) / gXrange)
        local angleB = math.atan((speedSq + discriminantSqrt) / gXrange)
        angle = self.usehigharc and math.max(angleA, angleB) or math.min(angleA, angleB)
    else
        --Not enough speed to reach endPos
        angle = 30 * DEGREES
    end

    local cosangleXspeed = math.cos(angle) * speed
    self.velocity.x = dx / range * cosangleXspeed
    self.velocity.z = dz / range * cosangleXspeed
    self.velocity.y = math.sin(angle) * speed
end

function ComplexProjectile:Launch(targetPos, attacker)
	local pos = self.inst:GetPosition()
	self.attacker = attacker

	if self.launchoffset and attacker then
	 	local offset = self.launchoffset
	    if attacker ~= nil and offset ~= nil then
	        local facing_angle = attacker.Transform:GetRotation() * DEGREES

	        pos.x = pos.x + offset.x * math.cos(facing_angle)
	        pos.y = pos.y + offset.y
	        pos.z = pos.z - offset.x * math.sin(facing_angle)

	        self.inst.Transform:SetPosition(pos:Get())
	    end
	else
		pos.y = pos.y + self.yOffset
	end

	self.inst.Transform:SetPosition(pos:Get())

    -- use targetoffset height, otherwise hit when you hit the ground
    targetPos.y = self.targetoffset ~= nil and self.targetoffset.y or 0

    self:CalculateTrajectory(pos, targetPos, self.horizontalSpeed)

	if self.onlaunchfn then
		self.onlaunchfn(self.inst)
	end

	self.inst:StartUpdatingComponent(self)
end

function ComplexProjectile:Hit(target)
	self.inst:StopUpdatingComponent(self)

	self.inst.Physics:SetMotorVel(0,0,0)
	self.inst.Physics:Stop()
	self.velocity = Vector3(0,0,0)

	if self.onhitfn then
		self.onhitfn(self.inst,self.attacker, target)
	end
end

function ComplexProjectile:OnUpdate(dt)
	self.inst.Physics:SetMotorVel(self.velocity.x, self.velocity.y, self.velocity.z)
	self.velocity.y = self.velocity.y + (self.gravity * dt)
	local pos = self.inst:GetPosition()
	if pos.y <= 0 and self.velocity.y < 0 then
		self:Hit()
	end
end

return ComplexProjectile