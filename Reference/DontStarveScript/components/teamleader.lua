
local TeamLeader = Class(function(self, inst )

	self.inst = inst
	self.team_type = "monster"
	self.min_team_size = 3
	self.max_team_size = 6
	self.team = {}
	self.threat = nil
	self.searchradius = 50
	self.theta = 0
	self.thetaincrement = 1
	self.radius = 5
	self.reverse = false
	self.timebetweenattacks = 3
	self.attackinterval = 3
	self.inst:StartUpdatingComponent(self)
	self.lifetime = 0
    self.attack_grp_size = nil
    self.chk_state = true

	self.maxchasetime = 30
	self.chasetime = 0
		
end)

local function getteamsize(team)
	local count = 0
		for k,v in pairs(team) do
			if v ~= nil and not v:HasTag("teamleader") then
				count = count + 1
			end
		end
	return count
end


function TeamLeader:OrganizeTeams()
	local teams = {}
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, self.searchradius)
	local oldestteam = 0
	for k,v in pairs(ents) do
		if v.components.teamleader and v.components.teamleader.threat == self.threat then
			table.insert(teams, v)
		end
	end

	local sort = function(w1, w2)
		if w1.components.teamleader.lifetime > w2.components.teamleader.lifetime then
			return true
		end
	end

	table.sort(teams, sort)
	
	if teams[1] ~= self.inst then return end

	local radius = 5
	local reverse = false
	local thetaincrement = 1
	local maxteam = 6

	for k,v in pairs(teams) do
		local leader = v.components.teamleader
		leader.radius = radius
		leader.reverse = reverse
		leader.thetaincrement = thetaincrement
		leader.max_team_size = maxteam
		radius = radius + 5
		reverse = not reverse
		thetaincrement = thetaincrement * 0.6
		maxteam = maxteam + 6
	end
end

function TeamLeader:IsTeamFull()
	if self.team and getteamsize(self.team) >= self.max_team_size then return true end
end

function TeamLeader:ValidMember(member)

	if member:HasTag(self.team_type) and
	   member.components.combat and not
	   (member.components.health and member.components.health:IsDead()) and not
	   member.components.teamattacker.inteam  then
		return true
	end
end

function TeamLeader:DisbandTeam()
    local team = {}
	for k,v in pairs(self.team) do
        team[k]=v
    end

	for k,v in pairs(team) do
		self:OnLostTeammate(v)
	end
	self.threat = nil
	self.team = {}
	self.inst:Remove()
end

function TeamLeader:TeamSizeControl()
	if getteamsize(self.team) > self.max_team_size then
		local teamcount = 0
        local team = {}
		for k,v in pairs(self.team) do
            team[k]=v
        end
		for k,v in pairs(team) do
			teamcount = teamcount + 1
			if teamcount > self.max_team_size then
				self:OnLostTeammate(v)
			end
		end
	end
end

function TeamLeader:NewTeammate(member)
	--listen for: Attacked, Death, OnAttackOther
	if self:ValidMember(member) then
		member.deathfn = function() self:OnLostTeammate(member) end
		member.attackedfn = function() self:BroadcastDistress(member) end
		member.attackedotherfn = function() 
			self.chasetime = 0
			member.components.teamattacker.orders = "HOLD"
			--member.components.combat.target = nil
		end

		self.team[member] = member
		self.inst:ListenForEvent("death", member.deathfn, member)
		self.inst:ListenForEvent("attacked", member.attackedfn, member)
		self.inst:ListenForEvent("onattackother", member.attackedotherfn, member)
		self.inst:ListenForEvent("onremove", member.deathfn, member)
		member.components.teamattacker.teamleader = self
		member.components.teamattacker.inteam = true
	end
end

function TeamLeader:BroadcastDistress(member)
	if not member then member = self.inst end

	if member:IsValid() then
		local x,y,z = member.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x,y,z, self.searchradius, { self.team_type } )  -- filter by tag?  { self.team_type }
		for k,v in pairs(ents) do
			if v ~= member and self:ValidMember(v) then
				self:NewTeammate(v)
			end
		end
	end
end

function TeamLeader:OnLostTeammate(member)
	if member and member:IsValid() then
		self.inst:RemoveEventCallback("death", member.deathfn, member)
		self.inst:RemoveEventCallback("attacked", member.attackedfn, member)
		self.inst:RemoveEventCallback("onattackother", member.attackedotherfn, member)
		self.inst:RemoveEventCallback("onremove", member.deathfn, member)
		self.team[member] = nil
		member.components.teamattacker.teamleader = nil
		member.components.teamattacker.order = nil
		member.components.teamattacker.inteam = false
		--member.components.combat.target = nil
	end
end

function TeamLeader:CanAttack()
	return getteamsize(self.team) >= self.min_team_size
end

function TeamLeader:CenterLeader()
	local updatedPos = nil
	local validMembers = 0
	for k,v in pairs(self.team) do            
        if not updatedPos then
            updatedPos = Vector3(k.Transform:GetWorldPosition() )
        else
            updatedPos = updatedPos + Vector3(k.Transform:GetWorldPosition() )
        end
        validMembers = validMembers + 1            
    end

    if updatedPos then
        updatedPos = updatedPos / validMembers
        self.inst.Transform:SetPosition(updatedPos:Get() )    
	end
end

function TeamLeader:GetFormationPositions()
		local target = self.threat
		local team = self.team
		local pt = Vector3(target.Transform:GetWorldPosition())
		local theta = self.theta
		local radius = self.radius
		local steps = getteamsize(team)

		for k,v in pairs(team) do
			radius = self.radius

			if v.components.teamattacker.orders == "WARN" then
				radius = self.radius - 1
			end 

			local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
			v.components.teamattacker.formationpos = pt + offset
			theta = theta - (2 * PI/steps)
		end
end

function TeamLeader:GiveOrders(order, num)
	local temp = {}

	for k,v in pairs(self.team) do
		if v ~= nil then
			v.components.teamattacker.orders = nil
			table.insert(temp, v)
		end
	end

	if num > #temp then num = #temp end
	local successfulorders = 0
	while successfulorders < num do
		local attempt = temp[math.random(1, #temp)]
		if attempt.components.teamattacker.orders == nil then
			attempt.components.teamattacker.orders = order
			successfulorders = successfulorders + 1
		end
	end

	for k,v in pairs(self.team) do
		if v ~= nil and v.components.teamattacker.orders == nil then
			v.components.teamattacker.orders = "HOLD"
		end
	end
end

function TeamLeader:GiveOrdersToAllWithOrder(order, oldorder)
	for k,v in pairs(self.team) do
		if v ~= nil and v.components.teamattacker.orders == oldorder then
			v.components.teamattacker.orders = order			
		end
	end
end

function TeamLeader:AllInState(state)
	local b = true
	for k,v in pairs(self.team) do
		if v ~= nil and
		   not ( self.chk_state and (v:HasTag("frozen") or v:HasTag("fire")) ) and
           not (v.components.teamattacker.orders == nil or v.components.teamattacker.orders == state) then
			b = false
		end
	end
	return b
end

function TeamLeader:IsTeamEmpty()
	if not next(self.team) then
        return true
    else
        return false
    end
end

function TeamLeader:SetNewThreat(threat)
	self.threat = threat
	self.inst:ListenForEvent("onremove", function() self:DisbandTeam() end, self.threat) --The threat has died
end

function TeamLeader:GetTheta(dt)
	if self.reverse then 
		return self.theta - (dt * self.thetaincrement)
	else
		return self.theta + (dt * self.thetaincrement)
	end
end

function TeamLeader:SetAttackGrpSize(val)
    self.attack_grp_size = val
end

function TeamLeader:NumberToAttack()
    if type(self.attack_grp_size) == "function" then
        return self.attack_grp_size()
    elseif type(self.attack_grp_size) == "number" then
        return self.attack_grp_size
    end

	if math.random() > 0.25 then return 1 else return 2 end
end

function TeamLeader:ManageChase(dt)

	self.chasetime = self.chasetime + dt
	if self.chasetime > self.maxchasetime then
		self:DisbandTeam()
	end

end

function TeamLeader:ValidateTeam()
    local team = {}
	for k,v in pairs(self.team) do
        team[k]=v
    end
	for k,v in pairs(team) do
		if not v:IsValid() then
			self:OnLostTeammate(v)
		end
	end
end

function TeamLeader:SetKeepThreatFn(fn)
	self.keepthreatfn = fn
end

function TeamLeader:KeepThreat()
	if self.threat and self.keepthreatfn then
		return self.keepthreatfn(self.inst, self.threat)
	else
		return true
	end
end

function TeamLeader:OnUpdate(dt)
	--self:ValidateTeam()
	self:ManageChase(dt)
	self:CenterLeader()
	self.lifetime = self.lifetime + dt
	self:OrganizeTeams()
	self:TeamSizeControl()

	if self.threat and self.threat:IsValid() and self:CanAttack() then	--Is there a target and is the team strong enough?

		self.theta = self:GetTheta(dt)  --Spin the formation!

		self:GetFormationPositions()

		if self:AllInState("HOLD") then
			self.timebetweenattacks = self.timebetweenattacks - dt

			if self.timebetweenattacks <= 0 then
				self.timebetweenattacks = self.attackinterval
				self:GiveOrders("WARN", self:NumberToAttack())
				self.inst:DoTaskInTime(0.5, function() self:GiveOrdersToAllWithOrder("ATTACK", "WARN") end)
            else
			end
		end
    else
	end

	if self:IsTeamEmpty() or (self.threat and not self.threat:IsValid()) or (self.threat and not self:KeepThreat()) then
		self:DisbandTeam()
	end
end

return TeamLeader
