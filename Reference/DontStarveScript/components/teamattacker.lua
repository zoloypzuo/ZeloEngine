local TeamAttacker = Class(function(self, inst)
	self.inst = inst
	self.inteam = false
	self.teamleader = nil
	self.formationpos = nil
	self.order = nil
	self.searchradius = 50
	self.leashdistance = 70
	self.inst:StartUpdatingComponent(self)
	self.team_type = "monster"
end)

function TeamAttacker:GetDebugString()
	local str = string.format("In Team %s, Current Orders: %s",
		tostring(self.inteam), self.orders or "NONE")
	return str
end

function TeamAttacker:SearchForTeam()	
	local pt = Vector3(self.inst.Transform:GetWorldPosition()) 
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, self.searchradius)
	local possibleleaders = {}

	for k,v in pairs(ents) do
        if v and v:HasTag(self.team_type) and v.components.teamleader then
            possibleleaders[v] = v 
        end
    end

    for k,v in pairs(possibleleaders) do
		if not v.components.teamleader:IsTeamFull() then
			v.components.teamleader:NewTeammate(self.inst)
			return true
		end
    end
end

function TeamAttacker:OnEntitySleep()

	if self.teamleader then
		self.teamleader:OnLostTeammate(self.inst)
	end
end

function TeamAttacker:ShouldGoHome()
    local homePos = self.inst.components.knownlocations:GetLocation("home")
    local x,y,z = self.inst.Transform:GetWorldPosition()
    return (homePos and distsq(homePos.x, homePos.z, x, z) > self.leashdistance*self.leashdistance)
end

function TeamAttacker:LeaveTeam()
	if self.teamleader then
		self.teamleader:OnLostTeammate(self.inst)
	end	
end

function TeamAttacker:OnUpdate(dt)
	if self:ShouldGoHome() then self:LeaveTeam() end

	if self.teamleader and self.teamleader:CanAttack() then --did you find a team?
		if self.orders == "HOLD" or self.orders == nil then --if you don't have anything to do.. look menacing
			--self.inst.components.combat.target = nil
			if self.formationpos then
				local destpos = self.formationpos
        		local mypos = Point(self.inst.Transform:GetWorldPosition())
        		if destpos and mypos then
					if distsq(destpos, mypos) >= 0.15 then	--if you're almost at your target just stop.
						self.inst.components.locomotor:GoToPoint(self.formationpos, nil, self.run)
					end
				end

				if self.inst.components.health.takingfiredamage then
					self.orders = "ATTACK"
				end

			end
		elseif self.orders == "WARN" then
			--self.inst.components.combat.target = nil
			if self.formationpos then
				local destpos = self.formationpos
        		local mypos = Point(self.inst.Transform:GetWorldPosition())
        		if destpos and mypos then
					if distsq(destpos, mypos) >= 0.15 then	--if you're almost at your target just stop.
						self.inst.components.locomotor:GoToPoint(self.formationpos, nil, self.run)
					end
				end
			end
		elseif self.orders == "ATTACK" then	--You have been told to attack. Get the target from your leader.
			self.inst.components.combat:SuggestTarget(self.teamleader.threat)
		end
	end
end

return TeamAttacker