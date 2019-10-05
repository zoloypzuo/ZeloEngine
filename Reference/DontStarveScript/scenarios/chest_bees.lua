chestfunctions = require("scenarios/chestfunctions")

loot = 
{
	{
		item = "honey",
		count = 6
	},
	{
		item = "honeycomb",
		count = 6
	},
	{
		item = "stinger",
		count = 5
	},
}

local function StartSpawningFn(inst)
	local fn = function(world)
		if inst.components.childspawner and GetWorld().components.seasonmanager:IsSummer() then
			inst.components.childspawner:StartSpawning()
		end
	end
	return fn
end

local function StopSpawningFn(inst)
	local fn = function(world)
		if inst.components.childspawner then
			inst.components.childspawner:StopSpawning()
		end
	end
	return fn
end

local function triggertrap(inst, scenariorunner)
	--spawn in loot
	chestfunctions.AddChestItems(inst, loot)
	--release all bees
	if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end
end

local function OnLoad(inst, scenariorunner)
	--listen for on open.
	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = "bee"
	inst.components.childspawner:SetRegenPeriod(TUNING.BEEHIVE_REGEN_TIME)
	inst.components.childspawner:SetSpawnPeriod(TUNING.BEEHIVE_RELEASE_TIME)
	inst.components.childspawner:SetMaxChildren(TUNING.BEEHIVE_BEES)
	if GetWorld().components.seasonmanager:IsSummer() then
		inst.components.childspawner:StartSpawning()
	end
	inst:ListenForEvent( "dusktime", StopSpawningFn(inst), GetWorld())
	inst:ListenForEvent( "daytime", StartSpawningFn(inst), GetWorld())

	chestfunctions.InitializeChestTrap(inst, scenariorunner, triggertrap)
end

local function OnDestroy(inst)
    chestfunctions.OnDestroy(inst)
end

return
{
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}