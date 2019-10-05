chestfunctions = require("scenarios/chestfunctions")
loot =
{
    {
        item = "spoiled_food",
        count = 10
    },
    {
        item = "blueprint",
        count = 4,
    },
}

local function triggertrap(inst, scenariorunner)
	--spawn poop cloud around area
    local perishamount = 0.5
    local player = GetPlayer()    
    local inv = player.components.inventory
    if inv then

        local pack = inv:GetEquippedItem(EQUIPSLOTS.BODY)

        local helm = inv:GetEquippedItem(EQUIPSLOTS.HEAD)

        if helm and helm.components.perishable then
            helm.components.perishable:ReducePercent(perishamount)
        end

        if pack and pack.components.container then
            for k = 1, pack.components.container.numslots do
                local item = pack.components.container.slots[k]
                if item and item.components.edible and item.components.perishable then
                    item.components.perishable:ReducePercent(perishamount)
                end
            end
        end

        for k = 1, inv.maxslots do
            local item = inv.itemslots[k]
            if item and item.components.edible and item.components.perishable then
                item.components.perishable:ReducePercent(perishamount)
            end
        end
    end
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local particle = SpawnPrefab("poopcloud")
    particle.Transform:SetScale(1.5, 1.5, 1.5)
    particle.Transform:SetPosition(pt.x, pt.y, pt.z)
    inst.SoundEmitter:PlaySound("dontstarve/common/toxic_cloud")
    --player.components.sanity:DoDelta(-TUNING.SANITY_MED)
    --go through player's inventory and find all spoilable objects, change spoil value.
end

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
end


local function OnLoad(inst, scenariorunner) 
    chestfunctions.InitializeChestTrap(inst, scenariorunner, triggertrap)
end

local function OnDestroy(inst)
    chestfunctions.OnDestroy(inst)
end


return
{
    OnCreate = OnCreate,
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}