chestfunctions = require("scenarios/chestfunctions")


local function OnCreate(inst, scenariorunner)

	local items = 
	{
		{
			item = "meat",
			count = 8,
		},
		{
			item = "berries",
			count = 8,
		},
		{
			item = "seeds",
			count = 10,
		},
		{
			item = "carrot",
			count = 2,
		},
		{
			item = "pumpkin",
			count = 2,
		},
		{
			item = "dragonfruit",
			count = 2,
		},	
		{
			item = "eggplant",
			count = 2,
		},
		{
			item = "tallbirdegg",
			count = 1,
		},
	}	
	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}
