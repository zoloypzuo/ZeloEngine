chestfunctions = require("scenarios/chestfunctions")
loot =
{
    {
        item = "log",
        count = 7
    },
    {
        item = "winterhat",
        count = 1
    },
    {
        item = "flint",
        count = 3
    },
}

local function OnCreate(inst, scenariorunner)
    chestfunctions.AddChestItems(inst, loot)
end

return
{
    OnCreate = OnCreate,
}
