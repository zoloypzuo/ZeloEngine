chestfunctions = require("scenarios/chestfunctions")


local function OnCreate(inst, scenariorunner)

	local items = 
	{
		{
			item = "cutgrass",
			count = 30,
		},
		{
			item = "log",
			count = 20,
		},
		{
			item = "flint",
			count = 10,
		},
		{
			item = "twigs",
			count = 30,
		},
		{
			item = "rocks",
			count = 20,
		},	
		{
			item = "goldnugget",
			count = 10,
		},
		{
			item = "gunpowder",
			count = 2,
		},
		{
			item = "silk",
			count = 6,
		},
		
	}	
	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}
