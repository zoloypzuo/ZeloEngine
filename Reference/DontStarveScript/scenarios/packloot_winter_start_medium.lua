chestfunctions = require("scenarios/chestfunctions")

local loot =
{
	{
		item = "cutgrass",
		count = math.random(20, 25),
		chance = 0.33,
	},
	{
		item = "log",
		count = math.random(10, 14),
		chance = 0.5,
	},
	{
		item = "heatrock",
	},
}

local l1 =
{
	{
		item = "flint",
		count = math.random(4, 10),
		chance = 0.66,
	},
	{
		item = "tools_blueprint",
	},
}

local l2 =
{
	{
		item = "torch",
	},
	{
		item = "twigs",
		count = math.random(20,25),
		chance = 0.5,
	},
}

local l3 =
{
	{
		item = "nightmarefuel",
		count = math.random(3, 5),
	},
	{
		item = "redgem",		
	},
	{
		item = "magic_blueprint",
	},
}

local l4 =
{
	{
		item = "nightmarefuel",
		count = math.random(3, 5),
	},
	{
		item = "bluegem",		
	},
	{
		item = "magic_blueprint",
	},
}

local l5 =
{
	{
		item = "livinglog",
		count = math.random(3,5),
	},
	{
		item = "magic_blueprint",
	},
}

local l6 =
{
	{
		item = "cutstone",
		count = math.random(4, 8),
	},
	{
		item = "boards",
		count = math.random(4, 8),
	},
	{
		item = "structures_blueprint",
	},
}

local l7 =
{
	{
		item = "silk",
		count = math.random(5, 10),
	},
	{
		item = "beefalowool",
		count = math.random(5, 10)
	},
	{
		item = "dress_blueprint",
	},
}

local l8 =
{
	{
		item = "survival_blueprint",
		count = 2,
	},
	{
		item = "refine_blueprint",
		count = 2,
	},
}

chanceloot = {l1,l2,l3,l4,l5,l6,l7,l8}

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
