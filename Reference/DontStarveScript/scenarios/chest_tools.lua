chestfunctions = require("scenarios/chestfunctions")


local function OnCreate(inst, scenariorunner)

	local items = 
	{
		{
			item = "axe",
		},
		{
			item = "spear",
		},
		{
			item = "shovel",
		},
		{
			item = "hammer",
		},
		{
			item = "pickaxe",
		},
		{
			item = "backpack_blueprint",
		},
		{
			item = "bedroll_straw_blueprint",
		},
		{
			item = "diviningrod_blueprint",
		},
		{
			item = "gunpowder_blueprint",
		},
	}	
	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}
