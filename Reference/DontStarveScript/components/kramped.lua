local Kramped = Class(function(self, inst)
    self.inst = inst
    
    self.actions = 0
    self.threshold = nil
    
    self.inst:ListenForEvent( "killed", function(inst,data) self:onkilledother(data.victim) end )
    self.timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD
    self.inst:StartUpdatingComponent(self)
end)

local SPAWN_DIST = 30

function Kramped:OnSave()
	return 
	{
		threshold = self.threshold,
		actions = self.actions
	}
end

function Kramped:onkilledother(victim)
	if victim and victim.prefab then
		if victim.prefab == "pigman" then
			if not victim.components.werebeast or not victim.components.werebeast:IsInWereState() then
				self:OnNaughtyAction(3)
			end
		elseif victim.prefab == "babybeefalo" then
			self:OnNaughtyAction(6)
		elseif victim.prefab == "teenbird" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "smallbird" then
			self:OnNaughtyAction(6)
		elseif victim.prefab == "beefalo" then
			self:OnNaughtyAction(4)
		elseif victim.prefab == "crow" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "robin" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "robin_winter" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "butterfly" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "rabbit" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "tallbird" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "bunnyman" then
			self:OnNaughtyAction(3)
		elseif victim.prefab == "penguin" then
			self:OnNaughtyAction(2)
		end
	end
end

function Kramped:OnLoad(data)
	self.actions = data.actions or self.actions
	self.threshold = data.threshold or self.threshold
end

function Kramped:GetDebugString()
	if self.actions and self.threshold and self.timetodecay then
		return string.format("Actions: %d / %d, decay in %2.2f", self.actions, self.threshold, self.timetodecay)
	else
		return "Actions: 0"
	end
end


function Kramped:OnUpdate(dt)
	
	if self.actions > 0 then
		self.timetodecay = self.timetodecay - dt
		
		if self.timetodecay < 0 then
			self.timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD
			self.actions = self.actions - 1
		end
	end
end



function Kramped:OnNaughtyAction(how_naughty)
	if TUNING.KRAMPUS_INCREASE_RAMP < 1 or TUNING.KRAMPUS_THRESHOLD_VARIANCE < 1 then return end

	if self.threshold == nil then
		self.threshold = TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)
	end

	self.actions = self.actions + (how_naughty or 1)
	self.timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD
	
	if self.actions >= self.threshold and self.threshold > 0 then
		
		local day = GetClock().numcycles
		
		local num_krampii = 1
		self.threshold = TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)
		self.actions = 0
		
		if day > TUNING.KRAMPUS_INCREASE_LVL1 then
			num_krampii = num_krampii + math.random(TUNING.KRAMPUS_INCREASE_RAMP)
		elseif day > TUNING.KRAMPUS_INCREASE_LVL2 then
			num_krampii = num_krampii + 1 + math.random(TUNING.KRAMPUS_INCREASE_RAMP)
		end

		for k = 1, num_krampii do
			self:MakeAKrampus()
		end
		
	else
		self.inst:DoTaskInTime(1 + math.random()*2, function()

			local snd = CreateEntity()
			snd.entity:AddTransform()
			snd.entity:AddSoundEmitter()
			snd.persists = false
			local theta = math.random() * 2 * PI
			local radius = 15
			local offset = Vector3(self.inst.Transform:GetWorldPosition()) +  Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
			snd.Transform:SetPosition(offset.x,offset.y,offset.z)
			
			local left = self.threshold - self.actions
			if left < 5 then
				snd.SoundEmitter:PlaySound("dontstarve/creatures/krampus/beenbad_lvl3")
			elseif left < 15 then
				snd.SoundEmitter:PlaySound("dontstarve/creatures/krampus/beenbad_lvl2")
			elseif left < 20 then
				snd.SoundEmitter:PlaySound("dontstarve/creatures/krampus/beenbad_lvl1")
			end
			snd:Remove()
		end)
	end
end

function Kramped:GetSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST
    
	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

function Kramped:MakeAKrampus()
	local pt = Vector3(self.inst.Transform:GetWorldPosition())
		
	local spawn_pt = self:GetSpawnPoint(pt)
	
	if spawn_pt then
	
		local kramp = SpawnPrefab("krampus")
		if kramp then
			kramp.Physics:Teleport(spawn_pt:Get())
			kramp:FacePoint(pt)
		end
	end
end


return Kramped
