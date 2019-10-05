chestfunctions = require("scenarios/chestfunctions")

local loot =
{
	{
		item = "cutgrass",
		count = math.random(3, 30),
	},
	{
		item = "log",
		count = math.random(3, 30),
	},
	{
		item = "minerhat_blueprint",
	},
}

local set1 =
{
	{
		item = "gunpowder",
		count = math.random(3, 5),
	},
	{
		item = "firestaff",
	},
}

local set2 =
{
	{
		item = "fishingrod_blueprint",
	},
}


chanceloot = {set1, set2}

local function pickchanceloot()
	return chanceloot[math.random(1, #chanceloot)]
end

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
	chestfunctions.AddChestItems(inst, pickchanceloot())
end

return 
{
	OnCreate = OnCreate
}
