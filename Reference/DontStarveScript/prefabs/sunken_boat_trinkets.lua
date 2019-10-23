local trinket_loot = {
    "redgem",
    "bluegem",
    "goldnugget",
    "purplegem",
    "feather_robin"
}

local function MakeTrinket(num)
    local name = "sunken_boat_trinket_" .. tostring(num)

    local prefabname = "common/inventory/" .. name

    local assets = {
        Asset("ANIM", "anim/sea_trinkets.zip"),
        Asset("INV_IMAGE", "sunken_boat_trinket_" .. num),
    }

    local function GiveClue(inst)
        -- /wolly
        local script = { }
        local clue, clue_start, clue_end = TheSim:GetSailorClue(num)
        if not clue_start then
            table.insert(script, Line(STRINGS.SUNKEN_BOAT_SQUAWKS[math.random(#STRINGS.SUNKEN_BOAT_SQUAWKS)], 1.5, nil))
        end
        table.insert(script, Line(clue, 3, false))
        if not clue_end then
            table.insert(script, Line(STRINGS.SUNKEN_BOAT_SQUAWKS[math.random(#STRINGS.SUNKEN_BOAT_SQUAWKS)], 1.5, nil))
        end
        return script, trinket_loot[num]
    end

    local function fn(Sim)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("sea_trinkets")
        inst.AnimState:SetBuild("sea_trinkets")
        inst.AnimState:PlayAnimation(tostring(num))

        inst:AddComponent("inspectable")
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inventoryitem")
        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.SUNKEN_BOAT_TRINKETS[num] or 3

        inst:AddTag("sunken_boat_special")

        inst.GiveCluefn = GiveClue

        return inst
    end

    return Prefab(prefabname, fn, assets)
end

local ret = {}
for k = 1, 5 do
    table.insert(ret, MakeTrinket(k))
end

return unpack(ret)
