chestfunctions = require("scenarios/chestfunctions")
loot =
{
    {
        item = "icestaff",
        count = 1,
        chance = 0.33
    },
    {
        item = "cutgrass",
        count = 40,
        chance = 0.66
    },
    {
        item = "twigs",
        count = 40,
        chance = 0.66
    },
    {
        item = "log",
        count = 20,
        chance = 0.66
    },
    {
        item = "winterhat",
        count = 1,
        chance = 0.8
    },
    {
        item = "trunkvest_summer",
        count = 1,
        chance = 0.8
    },
    {
        item = "axe",
        count = 1
    },
}

local function triggertrap(inst, scenariorunner)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/distant")
    GetWorld().components.seasonmanager:StartWinter()
    GetWorld().components.seasonmanager:Advance()
    GetWorld().components.seasonmanager:Advance()
    GetWorld().components.seasonmanager:ForcePrecip()
end

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
end


local function OnLoad(inst, scenariorunner) 
    chestfunctions.InitializeChestTrap(inst, scenariorunner, triggertrap)
end

local function OnDestroy(inst)
    chestfunctions.OnDestroy(inst)
end


return
{
    OnCreate = OnCreate,
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}