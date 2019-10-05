chestfunctions = require("scenarios/chestfunctions")

local loot =
{
	{
		item = "spoiled_food",
		count = math.random(80,300)
	},
}

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
end

return 
{
	OnCreate = OnCreate
}