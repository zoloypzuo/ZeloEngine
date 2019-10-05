chestfunctions = require("scenarios/chestfunctions")


local function OnCreate(inst, scenariorunner)

	local items = 
	{
		{
			item = "cutgrass",
			count = 6,
		},
		{
			item = "flint",
			count = 3,
		},
		{
			item = "twigs",
			count = 6,
		},
		{
			item = "log",
			count = 3,
		},
		{
			item = "goldnugget",
			count = 1,
		},
		{
			item = "axe",
		},
		
	}	
	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}
