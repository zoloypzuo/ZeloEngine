chestfunctions = require("scenarios/chestfunctions")


local function OnCreate(inst, scenariorunner)

	local items = 
	{

		{
			item = "slurtleslime",
			count = math.random(5, 12),
		},
		{
			item = "slurtle_shellpieces",
			count = math.random(3, 8),
		},
		{
			item = "lightbulb",
			count = math.random(4, 9)
		},
		{
			item = "armorsnurtleshell",
			chance = 0.05,
			initfn = function(item) if item.components.armor then item.components.armor:SetCondition(math.random(item.components.armor.maxcondition * 0.33, item.components.armor.maxcondition * 0.8)) end end
		},
		{
			item = "slurtlehat",
			chance = 0.05,
			initfn = function(item) if item.components.armor then item.components.armor:SetCondition(math.random(item.components.armor.maxcondition * 0.33, item.components.armor.maxcondition * 0.8)) end end
		},
		{
			item = "batbat",
			chance = 0.05,
			initfn = function(item) if item.components.finiteuses then item.components.finiteuses:SetUses(math.random(item.components.finiteuses.total * 0.33, item.components.finiteuses.total * 0.8)) end end
		},
		{
			item = "log",
			count = math.random(3, 10)
		},
		{
			item = "twigs",
			count = math.random(3, 10)
		},
		{
			item = "flint",
			count = math.random(3, 10)
		},
		{
			item = "healingsalve",
			count = math.random(2, 6)
		},
		{
			item = "guano",
			count = math.random(3, 10)
		},
		{
			item = "rocks",
			count = math.random(3, 10)
		},
		{
			item = "goldnugget",
			count = math.random(2,6)
		},
		{
			item = "silk",
			count = math.random(3, 10)
		},
		{
			item = "bluegem",
			chance = 0.25,
		},
		{
			item = "redgem",
			chance = 0.25,
		},
		{
			item = "bedroll_furry",
		},
	}

	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}
