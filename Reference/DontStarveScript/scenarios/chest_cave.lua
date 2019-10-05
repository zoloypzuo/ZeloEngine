chestfunctions = require("scenarios/chestfunctions")


local function OnCreate(inst, scenariorunner)

	local items = 
	{

		{
			item = "armorwood",
		},
		{
			item = "spear",
		},
		{
			item = "minerhat",
			count = 2
		},
		{
			item = "log",
			count = 20,
		},
		{
			item = "cutgrass",
			count = 40,
		},
		{
			item = "twigs",
			count = 40
		},
		{
			item = "flint",
			count = 40,
		},
		{
			item = "healingsalve",
			count = 10,
		},
	}

	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}
