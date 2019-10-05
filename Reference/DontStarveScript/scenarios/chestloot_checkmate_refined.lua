chestfunctions = require("scenarios/chestfunctions")

local loot =
{
	{
		item = "boards",
		count = math.random(5,7)
	},
	{
		item = "cutstone",
		count = math.random(2,4)
	},
	{
		item = "rope",
		count = math.random(4,5)
	},
	{
		item = "goldnugget",
		count = math.random(4,5)
	},
}

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
end

return
{
	OnCreate = OnCreate
}