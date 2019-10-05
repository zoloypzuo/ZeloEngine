local FlotsamFisher = Class(function(self, inst)
    self.inst = inst
    self.lootleft = 3
    self.flotsam_loot = {"boards", "rope", "log", "cutgrass"}
    self.decay_interval = TUNING.TOTAL_DAY_TIME
end)

function FlotsamFisher:TestWeights(numtest)
	numtest = numtest or 100

	local loots = {}

	for i = 0, numtest do
		local loot = self:GetFishType()
		if not loots[loot] then
			loots[loot] = 1
		else
			loots[loot] = loots[loot] + 1
		end
	end

	print("----------")
	dumptable(loots)
	print("----------")

end

function FlotsamFisher:GetFishType()
	local total_weight = 0

	for k,v in pairs(self.flotsam_loot) do
		total_weight = total_weight + v
	end

	local rand_weight = math.random() * total_weight

	-- print("Total Weight:", total_weight)
	-- print("Random Weight:", rand_weight)

	for k,v in pairs(self.flotsam_loot) do
		rand_weight = rand_weight - v
		if rand_weight <= 0 then
			--print("returning", k)
			return k
		end
	end 
end

function FlotsamFisher:Initialize(num)
	self.lootleft = num
    if self.onfishfn then
        self.onfishfn(self.inst, nil)
    end
end

function FlotsamFisher:DeltaFish(delta)
	self.lootleft = self.lootleft + delta

	if self.lootleft <= 0 then
		self.inst:Remove()
	end
end

function FlotsamFisher:Fish(fisher)
	--Launch a "fish" towards the player.
	local fish = SpawnPrefab(self:GetFishType())

	--direction from flotsam to player
	local pos = self.inst:GetPosition()
	local fisher_pos = fisher:GetPosition()

	local direction = fisher_pos - pos

	fish.Transform:SetPosition(pos:Get())

	local angle = math.atan2(direction.z, direction.x) + (math.random()*10-5)*DEGREES

    local sp = math.random(6, 7)
    fish.Physics:SetVel(sp*math.cos(angle), 30, sp*math.sin(angle))

	self:DeltaFish(-1)

	fish:DoTaskInTime(1.546, 
		function() 
			if not (fish.components.inventoryitem and fish.components.inventoryitem:IsHeld()) then
				if not fish:IsOnValidGround() then
					local fx = SpawnPrefab("splash_ocean")
				    local pos = fish:GetPosition()
					fx.Transform:SetPosition(pos.x, pos.y, pos.z)
					if fish:HasTag("irreplaceable") then
						fish.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
					else
						fish:Remove()
					end
				end
			end
		end)

	if self.onfishfn then
		self.onfishfn(self.inst, fisher)
	end

end

function FlotsamFisher:OnSave()
    return {
        lootleft = self.lootleft
    }
end

function FlotsamFisher:OnLoad(data)
    self:Initialize(data.lootleft)
end

return FlotsamFisher
