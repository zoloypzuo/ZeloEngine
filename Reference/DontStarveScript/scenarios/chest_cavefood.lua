chestfunctions = require("scenarios/chestfunctions")


local function OnCreate(inst, scenariorunner)

	local items = 
	{

		{
			item = "berries",
			count = math.random(5, 9),
			initfn = function(item) if item.components.perishable then item.components.perishable:SetPercent(math.random()) end end
		},
		{
			item = "carrot",
			count = math.random(3, 6),
			initfn = function(item) if item.components.perishable then item.components.perishable:SetPercent(math.random()) end end

		},
		{
			item = "lightbulb",
			count = math.random(4, 9),
			initfn = function(item) if item.components.perishable then item.components.perishable:SetPercent(math.random()) end end

		},
		{
			item = "batwing",
			initfn = function(item) if item.components.perishable then item.components.perishable:SetPercent(math.random()) end end

		},
		{
			item = "meat",
			count = math.random(2, 4),
			initfn = function(item) if item.components.perishable then item.components.perishable:SetPercent(math.random()) end end

		},
		{
			item = "smallmeat",
			count = math.random(2, 5),
			initfn = function(item) if item.components.perishable then item.components.perishable:SetPercent(math.random()) end end
		},
		{
			item = "monstermeat",
			count = math.random(2, 5),
			initfn = function(item) if item.components.perishable then item.components.perishable:SetPercent(math.random()) end end

		},

	}

	chestfunctions.AddChestItems(inst, items, 4)
end

return 
{
	OnCreate = OnCreate
}
