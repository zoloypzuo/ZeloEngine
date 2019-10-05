chestfunctions = require("scenarios/chestfunctions")

local loot =
{
	{
		item = "strawhat",
		count = 1
	},
	{
		item = "fireflies",
		count = math.random(2,4)
	},
	{
		item = "twigs",
		count = math.random(4,5)
	}
}

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
end

return 
{
	OnCreate = OnCreate
}